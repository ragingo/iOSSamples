//
//  VideoPlayer.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Foundation
import AVFoundation
import Combine

class VideoPlayer: VideoPlayerProtocol {
    private static let assetLoadKeys = [
        #keyPath(AVAsset.isPlayable)
    ]

    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var durationObservation: NSKeyValueObservation?
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

    // 動画長(単位：秒)
    var durationSubject: PassthroughSubject<Double, Never>

    // 再生位置(単位：秒)
    var positionSubject: PassthroughSubject<Double, Never>

    init() {
        playerLayer.player = player
        durationSubject = .init()
        positionSubject = .init()
    }

    deinit {
        invalidate()
    }

    func prepare() {
        initialiseAudio()
    }

    func invalidate() {
        durationObservation?.invalidate()
        durationObservation = nil

        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    func open(urlString: String) {
        invalidate()

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

    func seek(seconds: Double, completion: @escaping (() -> Void)) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { isFinished in
            if !isFinished {
                return
            }
            completion()
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
        switch status {
        case .loaded:
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
        default:
            return
        }

        // duration の監視
        durationObservation = player.currentItem?.observe(\.duration) { [weak self] item, _ in
            guard let self = self else { return }
            self.durationSubject.send(item.duration.seconds)
        }

        // 指定秒数の間隔で再生位置を通知
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.positionSubject.send(time.seconds)
        }
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
