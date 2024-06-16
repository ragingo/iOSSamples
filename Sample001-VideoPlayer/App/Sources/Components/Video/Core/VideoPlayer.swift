//
//  VideoPlayer.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Foundation
@preconcurrency import AVFoundation
import Combine
import CoreImage
import CoreVideo

final class VideoPlayer: VideoPlayerProtocol, @unchecked Sendable {
    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var imageGenerator: AVAssetImageGenerator?
    private var keyValueObservations: [NSKeyValueObservation?] = []
    private var timeObserver: Any?
    private var generatedImageCache: [Double: CGImage] = [:]
    private var filters: [CIFilter] = []

    var onAudioSampleBufferUpdate: ((CMSampleBuffer) -> Void)?

    var layer: CALayer {
        playerLayer
    }

    private(set) var isLiveStreaming = false

    // 再生中か
    var isPlaying: Bool {
        player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate
    }

    // バッファリング中か
    var isBuffering: Bool {
        player.timeControlStatus == .waitingToPlayAtSpecifiedRate
    }

    // 再生速度
    var rate: Float {
        get { player.rate }
        set { player.rate = newValue }
    }

    private(set) var loadStatusSubject = PassthroughSubject<VideoLoadStatus, Never>()
    private(set) var playStatusSubject = PassthroughSubject<VideoPlayStatus, Never>()
    // 動画長(単位：秒)
    private(set) var durationSubject = PassthroughSubject<Double, Never>()
    // 再生位置(単位：秒)
    private(set) var positionSubject = PassthroughSubject<Double, Never>()
    private(set) var isPlaybackLikelyToKeepUpSubject = PassthroughSubject<Bool, Never>()
    private(set) var isSeekingSubject = PassthroughSubject<Bool, Never>()
    private(set) var loadedBufferRangeSubject = PassthroughSubject<(Double, Double), Never>()
    private(set) var generatedImageSubject = PassthroughSubject<(Double, CGImage), Never>()
    private(set) var bandwidthsSubject = PassthroughSubject<[Int], Never>()

    init() {
        playerLayer.player = player
    }

    deinit {
        invalidate()
    }

    func prepare() {
        initialiseAudio()
    }

    func invalidate() {
        player.pause()

        for kvo in keyValueObservations {
            kvo?.invalidate()
        }
        keyValueObservations.removeAll()

        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }

        player.replaceCurrentItem(with: nil)
        playerLayer.player = nil

        generatedImageCache.removeAll()
    }

    func open(urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        if url.pathExtension == "m3u8" {
            isLiveStreaming = true
            let bandwidths = await Self.parseMasterPlaylist(url: url)
            DispatchQueue.main.async { [weak self] in
                self?.bandwidthsSubject.send(bandwidths)
            }
        }
        // 非同期でロード開始
        let asset = AVURLAsset(url: url)
        do {
            let isPlayable = try await asset.load(.isPlayable)
            guard isPlayable else {
                return
            }
            await onAssetLoaded(asset)
        } catch {
            print(error)
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func seek(seconds: Double) {
        isSeekingSubject.send(true)
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] isFinished in
            guard let self = self else { return }
            if !isFinished {
                return
            }
            self.isSeekingSubject.send(false)
        }
    }

    // completion はメインスレッドを保証する
    // HLS の場合、Iフレームのみのプレイリストというものが無い場合、 generateCGImagesAsynchronously は失敗するらしい ><
    // https://stackoverflow.com/questions/32112205/m3u8-file-avassetimagegenerator-error
    func requestGenerateImage(time: Double, size: CGSize) {
        if let image = generatedImageCache[time] {
            generatedImageSubject.send((time, image))
            return
        }

        var times: [NSValue] = []
        times += [NSValue(time: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))]

        guard let imageGenerator = self.imageGenerator else { return }
        imageGenerator.maximumSize = size

        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            guard error == nil else { return }
            guard result == .succeeded else { return }
            guard let image = image else { return }
            let requestedSeconds = floor(requestedTime.seconds)
            let actualSeconds = floor(actualTime.seconds)
            if !requestedSeconds.isEqual(to: actualSeconds) {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // 雑に枚数上限無しで保持させてみる
                self.generatedImageCache[requestedSeconds] = image
                self.generatedImageSubject.send((requestedSeconds, image))
            }
        }
    }

    func cancelImageGenerationRequests() {
        imageGenerator?.cancelAllCGImageGeneration()
    }

    func changePreferredPeakBitRate(value: Int) {
        player.currentItem?.preferredPeakBitRate = Double(value)
    }

    func addFilter(filter: CIFilter) {
        self.filters += [filter]
    }

    func clearFilters() {
        filters.removeAll()
    }

    // 音声関連の初期化
    private func initialiseAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }
}

// MARK: - Callbacks
extension VideoPlayer {
    // AVURLAsset.loadValuesAsynchronously 完了時
    @MainActor
    private func onAssetLoaded(_ asset: AVURLAsset) async {
        if isLiveStreaming {
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
        } else {
            let composition = AVMutableComposition()
            let playerItem = await Self.createVideoPlayerItem(asset: asset, composition: composition)
            player.replaceCurrentItem(with: playerItem)
            playerItem.videoComposition = createVideoComposition(composition: composition)
        }

        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator?.requestedTimeToleranceBefore = .zero
        imageGenerator?.requestedTimeToleranceAfter = .zero

        // AVPlayerItem のプロパティの監視
        keyValueObservations += [player.currentItem?.observe(\.status, changeHandler: { [weak self] in self?.onStatusChanged(item: $0, value: $1) })]
        keyValueObservations += [player.currentItem?.observe(\.duration, changeHandler: { [weak self] in self?.onDurationChanged(item: $0, value: $1) })]
        keyValueObservations += [player.currentItem?.observe(\.isPlaybackLikelyToKeepUp, changeHandler: { [weak self] in self?.onPlaybackLikelyToKeepUpChanged(item: $0, value: $1) })]
        keyValueObservations += [player.currentItem?.observe(\.loadedTimeRanges, changeHandler: { [weak self] in self?.onLoadedTimeRangesChanged(item: $0, value: $1) })]

        // AVPlayer のプロパティの監視
        keyValueObservations += [player.observe(\.timeControlStatus, changeHandler: { [weak self] in self?.onTimeControlStatusChanged(player: $0, value: $1)})]

        // 指定秒数の間隔で再生位置を通知
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] in self?.onTimeObserverCall(time: $0) })
    }

    // AVPlayerItem.status 変更時
    private func onStatusChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<AVPlayerItem.Status>) {
        switch item.status {
        case .readyToPlay:
            loadStatusSubject.send(.readyToPlay)
        case .unknown:
            loadStatusSubject.send(.unknown)
        case .failed:
            loadStatusSubject.send(.failed)
        @unknown default:
            fatalError()
        }
    }

    // AVPlayerItem.duration 変更時
    private func onDurationChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<CMTime>) {
        durationSubject.send(item.duration.seconds)
    }

    // AVPlayerItem.isPlaybackLikelyToKeepUp 変更時
    private func onPlaybackLikelyToKeepUpChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<Bool>) {
        isPlaybackLikelyToKeepUpSubject.send(item.isPlaybackLikelyToKeepUp)
    }

    // AVPlayerItem.loadedTimeRanges 変更時
    private func onLoadedTimeRangesChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<[NSValue]>) {
        guard let ranges = item.loadedTimeRanges as? [CMTimeRange] else { return }
        if ranges.isEmpty {
            return
        }
        let range = ranges[0]
        let start = floor(range.start.seconds)
        let end = floor(range.end.seconds)
        if start.isNaN || start.isInfinite || end.isNaN || end.isInfinite {
            return
        }
        loadedBufferRangeSubject.send((start, end))
    }

    // AVPlayer.timeControlStatus 変更時
    private func onTimeControlStatusChanged(player: AVPlayer, value: NSKeyValueObservedChange<AVPlayer.TimeControlStatus>) {
        switch player.timeControlStatus {
        case .paused:
            playStatusSubject.send(.paused)
        case .waitingToPlayAtSpecifiedRate:
            playStatusSubject.send(.buffering)
        case .playing:
            playStatusSubject.send(.playing)
        @unknown default:
            fatalError()
        }
    }

    // AVPlayer.addPeriodicTimeObserver() で指定した関数
    // 定期的にメインスレッドで実行される
    private func onTimeObserverCall(time: CMTime) {
        positionSubject.send(time.seconds)
    }
}

extension VideoPlayer {
    // 画質(bandwidth)一覧を降順で取得
    private static func parseMasterPlaylist(url: URL) async -> [Int] {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        var m3u8Content: String = ""

        // .m3u8 ファイルの中身を取得
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else {
                return []
            }
            if ![200].contains(response.statusCode) {
                return []
            }
            guard let content = String(data: data, encoding: .utf8) else {
                return []
            }
            m3u8Content = content
        } catch {
            print(error)
        }

        guard let regex = try? NSRegularExpression(pattern: #"[:,]BANDWIDTH=(\d+)(\,|$)"#) else {
            return []
        }

        // 改行で分割
        let lines = m3u8Content.split(separator: "\n")
        // #EXT-X-STREAM-INF で始まる行だけ取り出す
        let streamInfs = lines.filter { line in line.starts(with: "#EXT-X-STREAM-INF:") }
        // BANDWIDTH=xxx の値だけ取り出す
        let bandwidths = streamInfs
            .compactMap { inf -> Int? in
                let inputRange = NSRange(location: 0, length: inf.count)
                guard let result = regex.firstMatch(in: String(inf), range: inputRange) else {
                    return nil
                }
                let group1 = result.range(at: 1)
                let value = (inf as NSString).substring(with: group1)
                return Int(value)
            }
            .sorted()

        return bandwidths
    }

    private static func createVideoPlayerItem(asset: AVAsset, composition: AVMutableComposition) async -> AVPlayerItem {
        let videoTrack = try? await asset.loadTracks(withMediaType: .video).first
        let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first
        let duration = try? await asset.load(.duration)

        if let videoTrack, let duration {
            let addedVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let range = CMTimeRange(start: .zero, duration: duration)
            try? addedVideoTrack?.insertTimeRange(range, of: videoTrack, at: .zero)
        }

        if let audioTrack, let duration {
            let addedAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            let range = CMTimeRange(start: .zero, duration: duration)
            try? addedAudioTrack?.insertTimeRange(range, of: audioTrack, at: .zero)
        }

        return await AVPlayerItem(asset: composition)
    }

    // AVVideoComposition を作って返す
    private func createVideoComposition(composition: AVMutableComposition) -> AVMutableVideoComposition? {
        let videoComposition = AVMutableVideoComposition(asset: composition) { [weak self] request in
            guard let self = self else {
                request.finish(with: request.sourceImage, context: nil)
                return
            }

            var nextInputImage = request.sourceImage.clampedToExtent()

            for filter in self.filters {
                filter.setValue(nextInputImage, forKey: kCIInputImageKey)
                guard let outputImage = filter.outputImage else { continue }
                nextInputImage = outputImage.cropped(to: nextInputImage.extent)
            }

            request.finish(with: nextInputImage, context: nil)
        }

        videoComposition.renderSize = composition.naturalSize

        return videoComposition
    }
}
