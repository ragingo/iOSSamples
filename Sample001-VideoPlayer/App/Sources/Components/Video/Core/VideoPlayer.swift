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

@MainActor
final class VideoPlayer: VideoPlayerProtocol {
    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var imageGenerator: ImageGenerator?
    private var keyValueObservations: [NSKeyValueObservation?] = []
    private var timeObserver: Any?

    var layer: CALayer {
        playerLayer
    }

    let state: VideoPlayerState = .init()

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

    func requestGenerateImage(time: Double, size: CGSize) {
        Task {
            await imageGenerator?.cancel()
        }

        guard let imageGenerator else { return }

        Task.detached(name: "\(self)", priority: .background) {
            let result = try await imageGenerator.generateImages(times: [time], size: size)
            await MainActor.run {
                for (time, image) in result {
                    self.state.seekThumbnail = .init(time: time, image: image)
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
        keyValueObservations += [
            player.observe(\.rate) { [weak self] item, value in
                guard let self else { return }
                Task { @MainActor in
                    state.rate = value.newValue ?? 1.0
                }
            }
        ]

        let duration = try await asset.load(.duration)
        state.duration = duration.seconds

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
            state.isReady = true
        case .unknown:
            state.isReady = false
        case .failed:
            state.isReady = false
        @unknown default:
            fatalError()
        }
    }

    // AVPlayerItem.isPlaybackLikelyToKeepUp 変更時
    private func onPlaybackLikelyToKeepUpChanged(item: AVPlayerItem) {
        state.isBuffering = true
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
        state.loadedBufferRange = .init(start: start, end: end)
    }

    // AVPlayer.timeControlStatus 変更時
    private func onTimeControlStatusChanged(player: AVPlayer) {
        switch player.timeControlStatus {
        case .paused:
            state.isPlaying = false
            state.isBuffering = false
        case .waitingToPlayAtSpecifiedRate:
            state.isPlaying = true
            state.isBuffering = true
        case .playing:
            state.isPlaying = true
            state.isBuffering = false
        @unknown default:
            fatalError()
        }
    }

    // AVPlayer.addPeriodicTimeObserver() で指定した関数
    // 定期的にメインスレッドで実行される
    private func onTimeObserverCall(time: CMTime) {
        state.position = time.seconds
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

extension VideoPlayer: VideoPlaybackControl {
    // 再生速度
    func rate(_ value: Float) {
        player.rate = value
    }

    func open(urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        if url.pathExtension == "m3u8" {
            state.videoQualities = await Self.parseMultivariantPlaylist(url: url)
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
        state.isSeeking = true
        defer {
            state.isSeeking = false
        }
        let position = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let isFinished = await player.seek(to: position)
        if !isFinished {
            return
        }
    }
}
