//
//  VideoListView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

struct VideoListView: View {
    @ObservedObject private var viewModel: VideoListViewModel

    init(viewModel: VideoListViewModel = VideoListViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            NavigationView {
                List(viewModel.videos) { video in
                    NavigationLink(destination: VideoView(video: video)) {
                        Text(video.title)
                    }
                }
                .refreshable {
                    await viewModel.fetchItems()
                }
                .navigationTitle("videos")
            }
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetchItems()
        }
    }
}
