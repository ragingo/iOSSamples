//
//  VideoControllerView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/06.
//

import SwiftUI

#if DEBUG

private let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
private let player = VideoPlayer()

struct VideoControllerView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        //        VideoControllerView(player: player)
        //            .onAppear {
        //                player.open(urlString: videoURL)
        //            }
    }
}

#endif
