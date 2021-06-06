//
//  VideoPlayerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI
import UIKit

// プレーヤ
struct VideoPlayerView: View {
    private let player: VideoPlayerProtocol
    @State private var isReady = false
    @State private var isBuffering = false

    init(player: VideoPlayerProtocol = VideoPlayer()) {
        self.player = player
    }

    var body: some View {
        ZStack {
            VStack {
                VideoSurfaceView(playerLayer: player.layer)
                    .padding(.horizontal, 8)
                VideoControllerView(player: player)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            if !isReady || isBuffering {
                ProgressView()
            }
        }
        .onAppear {
            player.prepare()
        }
        .onDisappear {
            player.invalidate()
        }
        .onReceive(player.loadStatusSubject) { status in
            if status == .readyToPlay {
                isReady = true
            }
        }
        .onReceive(player.playStatusSubject) { status in
            isBuffering = status == .buffering
        }
        .onReceive(player.isPlaybackLikelyToKeepUpSubject) { value in
            isBuffering = !value
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            player.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            player.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            player.play()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            player.play()
        }
    }

    func open(urlString: String) {
        player.open(urlString: urlString)
    }
}
