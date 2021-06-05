//
//  VideoListView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

// samples: https://hls-js.netlify.app/demo/

struct VideoListView: View {
    @State private var videoURLs = [
        "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
        "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
        "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
        "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        "https://test-streams.mux.dev/test_001/stream.m3u8"
    ]

    var body: some View {
        NavigationView {
            List(0..<videoURLs.count) { i in
                NavigationLink(destination: VideoView(urlString: videoURLs[i])) {
                    Text(videoURLs[i])
                }
            }
            .navigationTitle("videos")
        }
    }
}
