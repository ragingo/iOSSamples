//
//  VideoPlayer.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Foundation
import AVFoundation
import Combine

class VideoPlayer {
    private static let assetLoadKeys = [
        #keyPath(AVAsset.isPlayable)
    ]

    private let playerLayer = AVPlayerLayer()
    private let player = AVPlayer()
    private var durationObservation: NSKeyValueObservation?

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

    init() {
        playerLayer.player = player
        durationSubject = .init()
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
    }

    // 音声関連の初期化
    private func initialiseAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }
}
