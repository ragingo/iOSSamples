//
//  VideoControllerView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/06.
//

import SwiftUI

#if DEBUG

#Preview {
    let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    let player = VideoPlayer()

    VideoControllerView(player: player, thumbnailPreviewPosition: .constant(0), bandwidths: .constant([1, 2, 3]))
        .onAppear {
            Task {
                await player.open(urlString: videoURL)
            }
        }
}

#endif
