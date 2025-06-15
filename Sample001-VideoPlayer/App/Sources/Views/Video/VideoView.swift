//
//  VideoView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

struct VideoView: View {
    @State private var viewModel: VideoViewModel
    @State private var videoPlayerView: VideoPlayerView?

    init(video: Video) {
        viewModel = VideoViewModel(video: video)
    }

    var body: some View {
        VStack {
            Text(viewModel.video.title)
            videoPlayerView
        }
        .onAppear {
            videoPlayerView = VideoPlayerView()
            videoPlayerView?.open(urlString: viewModel.video.url)
        }
    }
}

#Preview {
    let video = Video(id: 1, title: "a", url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    VideoView(video: video)
}
