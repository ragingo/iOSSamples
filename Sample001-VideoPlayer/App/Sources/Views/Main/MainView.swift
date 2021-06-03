//
//  MainView.swift
//  App
//
//  Created by ragingo on 2021/06/01.
//

import SwiftUI

// https://bitmovin.com/mpeg-dash-hls-examples-sample-streams/
let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"

// メイン画面
struct MainView: View {
    private let videoPlayerView = VideoPlayerView()

    var body: some View {
        VStack {
            videoPlayerView
        }
        .onAppear {
            videoPlayerView.open(urlString: videoURL)
        }
    }
}
