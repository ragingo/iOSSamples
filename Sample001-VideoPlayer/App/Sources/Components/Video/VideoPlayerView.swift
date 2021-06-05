//
//  VideoPlayerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

// プレーヤ
struct VideoPlayerView: View {
    private let player: VideoPlayerProtocol

    init(player: VideoPlayerProtocol = VideoPlayer()) {
        self.player = player
    }

    var body: some View {
        VStack {
            VideoSurfaceView(playerLayer: player.layer)
                .padding(.horizontal, 8)
            VideoControllerView(player: player)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .onAppear {
            player.prepare()
        }
        .onDisappear {
            player.invalidate()
        }
    }

    func open(urlString: String) {
        player.open(urlString: urlString)
    }
}
