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
    func requestGenerateImage(time: Double, completion: @escaping ((CGImage) -> Void)) {
        var times: [NSValue] = []
        times += [NSValue(time: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))]

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            guard let imageGenerator = self.imageGenerator else { return }
            imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (_, image, _, _, _) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    func cancelImageGenerationRequests() {
        imageGenerator?.cancelAllCGImageGeneration()
    }

    // TODO: 重くて使い物にならないからなんとかする。
    func requestGenerateImage2(time: Double, completion: @escaping ((CGImage) -> Void)) {
        print("start requestGenerateImage2(\(time))")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            guard let output = self.videoOutput else { return }

            let cmtime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: cmtime, itemTimeForDisplay: nil) else {
                return
            }

            let image = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            guard let imageRef = context.createCGImage(image, from: rect) else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                print("finish requestGenerateImage2(\(time))")
                completion(imageRef)
            }
        }
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
