//
//  VideoListView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

struct VideoListView: View {
    @State private var viewModel: VideoListViewModel
    @State private var searchText = ""

    private var filteredVideos: [Video] {
        viewModel.videos
            .filter { video in
                searchText.isEmpty ? true : video.title.contains(searchText)
            }
    }

    init(viewModel: VideoListViewModel = VideoListViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            NavigationView {
                List(filteredVideos) { video in
                    NavigationLink(destination: VideoView(video: video)) {
                        Text(video.title)
                            .lineLimit(1)
                    }
                }
                .refreshable {
                    await viewModel.fetchItems()
                }
                .searchable(text: $searchText)
                .autocapitalization(.none)
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

#Preview {
    VideoListView()
}
