//
//  VideoListView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

// samples: https://hls-js.netlify.app/demo/

struct VideoListView: View {
    @ObservedObject private var viewModel: VideoListViewModel

    init(viewModel: VideoListViewModel = VideoListViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            NavigationView {
                List(viewModel.videos) { video in
                    NavigationLink(destination: VideoView(urlString: video.url)) {
                        Text(video.title)
                    }
                }
                .navigationTitle("videos")
            }
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }
}
