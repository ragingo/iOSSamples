//
//  VideoPlayerView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/06.
//

import SwiftUI

#if DEBUG

#Preview {
    let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    let playerView = VideoPlayerView()

    VStack {
        playerView
    }
    .onAppear {
        playerView.open(urlString: videoURL)
    }
}

#endif
