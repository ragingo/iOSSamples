//
//  VideoPlayer.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Foundation
import AVFoundation
import Combine
import CoreImage
import CoreVideo

class VideoPlayer: VideoPlayerProtocol {
    private static let assetLoadKeys = [
        #keyPath(AVAsset.isPlayable)
    ]

    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var imageGenerator: AVAssetImageGenerator?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var keyValueObservations: [NSKeyValueObservation?] = []
    private var timeObserver: Any?
    private var generatedImageCache: [Double: CGImage] = [:]

    var layer: CALayer {
        playerLayer
    }

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

    var loadStatusSubject = PassthroughSubject<VideoLoadStatus, Never>()
    var playStatusSubject = PassthroughSubject<VideoPlayStatus, Never>()
    // 動画長(単位：秒)
    var durationSubject = PassthroughSubject<Double, Never>()
    // 再生位置(単位：秒)
    var positionSubject = PassthroughSubject<Double, Never>()
    var isPlaybackLikelyToKeepUpSubject = PassthroughSubject<Bool, Never>()
    var isSeekingSubject = PassthroughSubject<Bool, Never>()
    var loadedBufferRangeSubject = PassthroughSubject<(Double, Double), Never>()
    var generatedImageSubject = PassthroughSubject<(Double, CGImage), Never>()

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
    }

    func open(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        // 非同期でロード開始
        let asset = AVURLAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: Self.assetLoadKeys) { [weak self] in
            guard let self = self else { return }
            self.onAssetLoaded(asset)
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

    // AVURLAsset.loadValuesAsynchronously 完了時
    private func onAssetLoaded(_ asset: AVURLAsset) {
        for key in Self.assetLoadKeys {
            var error: NSError?
            let status = asset.statusOfValue(forKey: key, error: &error)
            if status != .loaded {
                return
            }
        }

        var error: NSError?
        let status = asset.statusOfValue(forKey: #keyPath(AVAsset.isPlayable), error: &error)
        assert(status == .loaded)

        videoOutput = AVPlayerItemVideoOutput()

        let playerItem = AVPlayerItem(asset: asset)
        playerItem.add(videoOutput!)
        player.replaceCurrentItem(with: playerItem)

        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator?.requestedTimeToleranceBefore = .zero
        imageGenerator?.requestedTimeToleranceAfter = .zero

        // AVPlayerItem のプロパティの監視
        keyValueObservations += [player.currentItem?.observe(\.status, changeHandler: onStatusChanged)]
        keyValueObservations += [player.currentItem?.observe(\.duration, changeHandler: onDurationChanged)]
        keyValueObservations += [player.currentItem?.observe(\.isPlaybackLikelyToKeepUp, changeHandler: onPlaybackLikelyToKeepUpChanged)]
        keyValueObservations += [player.currentItem?.observe(\.loadedTimeRanges, changeHandler: onLoadedTimeRangesChanged)]

        // AVPlayer のプロパティの監視
        keyValueObservations += [player.observe(\.timeControlStatus, changeHandler: onTimeControlStatusChanged)]

        // 指定秒数の間隔で再生位置を通知
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: onTimeObserverCall)
    }

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

    private func onDurationChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<CMTime>) {
        durationSubject.send(item.duration.seconds)
    }

    private func onPlaybackLikelyToKeepUpChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<Bool>) {
        isPlaybackLikelyToKeepUpSubject.send(item.isPlaybackLikelyToKeepUp)
    }

    private func onLoadedTimeRangesChanged(item: AVPlayerItem, value: NSKeyValueObservedChange<[NSValue]>) {
        guard let ranges = item.loadedTimeRanges as? [CMTimeRange] else { return }
        if ranges.isEmpty {
            return
        }
        let range = ranges[0]
        let start = floor(range.start.seconds)
        let end = floor(range.end.seconds)
        loadedBufferRangeSubject.send((start, end))
    }

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

    private func onTimeObserverCall(time: CMTime) {
        positionSubject.send(time.seconds)
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
