//
//  VideoPlayerView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/06.
//

import SwiftUI

#if DEBUG

private let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
private let playerView = VideoPlayerView()

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            playerView
        }
        .onAppear {
            playerView.open(urlString: videoURL)
        }
    }
}

#endif
