//
//  VideoView.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

struct VideoView: View {
    @State private var videoPlayerView: VideoPlayerView?
    private let urlString: String

    init(urlString: String) {
        self.urlString = urlString
    }

    var body: some View {
        VStack {
            videoPlayerView
        }
        .onAppear {
            videoPlayerView = VideoPlayerView()
            videoPlayerView?.open(urlString: urlString)
        }
    }
}
