//
//  VideoPlayerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import AVFoundation
import SwiftUI

// プレーヤ
struct VideoPlayerView: View {
    private let player = AVPlayer()

    var body: some View {
        VStack {
            VideoSurfaceView(player: player)
            VideoControllerView(position: .constant(.zero), player: player)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .onAppear {
            initialiseAudio()
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

    func open(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
    }
}
