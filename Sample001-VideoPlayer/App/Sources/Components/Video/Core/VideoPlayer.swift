//
//  VideoPlayer.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import AVFoundation
import Combine
import CoreImage
import CoreVideo
import Foundation
import os

actor ImageGenerator: Sendable {
    private let imageGenerator: AVAssetImageGenerator
    private var cache: [Double: CGImage] = [:]

    init(asset: AVAsset) {
        imageGenerator = .init(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
    }

    func generateImage(time: Double, size: CGSize) async throws -> (Double, CGImage) {
        if let image = cache[time] {
            return (time, image)
        }

        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let (image, time) = try await imageGenerator.__generateCGImage(for: cmTime)
        return (time.seconds, image)
    }

    func generateImages(times: [Double], size: CGSize) async throws -> [Double: CGImage] {
        imageGenerator.maximumSize = size

        return try await withThrowingTaskGroup(of: (Double, CGImage?).self) { group in
            var result: [Double: CGImage] = [:]
            for time in times {
                group.addTask(name: "\(type(of: self))", priority: .background) { [weak self] in
                    guard let self else { return (time, nil) }
                    return try await generateImage(time: time, size: size)
                }
            }
            for try await (time, image) in group {
                result[time] = image
            }
            cache.merge(result) { $1 }
            return result
        }
    }

    func cancel() {
        imageGenerator.cancelAllCGImageGeneration()
    }
}

@MainActor
final class VideoPlayer: VideoPlayerProtocol {
    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var imageGenerator: ImageGenerator?
    private var keyValueObservations: [NSKeyValueObservation?] = []
    private var timeObserver: Any?
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

    isolated deinit {
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
    }

    func open(urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        if url.pathExtension == "m3u8" {
            isLiveStreaming = true
            let bandwidths = await Self.parseMultivariantPlaylist(url: url)
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
            try await onAssetLoaded(asset)
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

    func seek(seconds: Double) async {
        isSeekingSubject.send(true)
        let position = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let isFinished = await player.seek(to: position)
        if !isFinished {
            return
        }
        self.isSeekingSubject.send(false)
    }

    func requestGenerateImage(time: Double, size: CGSize) {
        Task {
            await imageGenerator?.cancel()
        }

        guard let imageGenerator else { return }

        Task.detached(name: "\(self)", priority: .background) {
            let result = try await imageGenerator.generateImages(times: [time], size: size)
            await MainActor.run {
                for (time, image) in result {
                    self.generatedImageSubject.send((time, image))
                }
            }
        }
    }

    func cancelImageGenerationRequests() {
        Task {
            await imageGenerator?.cancel()
        }
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
    private func onAssetLoaded(_ asset: AVURLAsset) async throws {
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        imageGenerator = ImageGenerator(asset: asset)

        // AVPlayerItem のプロパティの監視
        keyValueObservations += [
            playerItem.observe(\.status) { [weak self] item, value in
                guard let self else { return }
                Task { @MainActor in
                    self.onStatusChanged(item: item, value: value)
                }
            }
        ]
        keyValueObservations += [
            playerItem.observe(\.isPlaybackLikelyToKeepUp) { [weak self] item, _ in
                guard let self else { return }
                Task { @MainActor in
                    self.onPlaybackLikelyToKeepUpChanged(item: item)
                }
            }
        ]
        keyValueObservations += [
            playerItem.observe(\.loadedTimeRanges) { [weak self] item, _ in
                guard let self else { return }
                Task { @MainActor in
                    self.onLoadedTimeRangesChanged(item: item)
                }
            }
        ]

        // AVPlayer のプロパティの監視
        keyValueObservations += [
            player.observe(\.timeControlStatus) { [weak self] item, _ in
                guard let self else { return }
                Task { @MainActor in
                    self.onTimeControlStatusChanged(player: item)
                }
            }
        ]

        let duration = try await asset.load(.duration)
        durationSubject.send(duration.seconds)

        // 指定秒数の間隔で再生位置を通知
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            Task { @MainActor in
                self.onTimeObserverCall(time: time)
            }
        }
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

    // AVPlayerItem.isPlaybackLikelyToKeepUp 変更時
    private func onPlaybackLikelyToKeepUpChanged(item: AVPlayerItem) {
        isPlaybackLikelyToKeepUpSubject.send(item.isPlaybackLikelyToKeepUp)
    }

    // AVPlayerItem.loadedTimeRanges 変更時
    private func onLoadedTimeRangesChanged(item: AVPlayerItem) {
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
    private func onTimeControlStatusChanged(player: AVPlayer) {
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
    private static func parseMultivariantPlaylist(url: URL) async -> [Int] {
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
        let bandwidths =
            streamInfs
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
}
