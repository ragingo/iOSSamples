//
//  VideoListView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

struct VideoListView: View {
    @ObservedObject private var viewModel: VideoListViewModel
    @State private var isLoading = false

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
                .refreshable {
                    isLoading = true
                    await viewModel.fetchItems()
                    isLoading = false
                }
                .navigationTitle("videos")
            }
            if isLoading {
                ProgressView()
            }
        }
        .task {
            isLoading = true
            await viewModel.fetchItems()
            isLoading = false
        }
    }
}
