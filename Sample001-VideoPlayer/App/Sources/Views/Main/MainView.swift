//
//  MainView.swift
//  App
//
//  Created by ragingo on 2021/06/01.
//

import SwiftUI
import AVKit

// https://bitmovin.com/mpeg-dash-hls-examples-sample-streams/
let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"

struct MainView: View {
    var body: some View {
        VideoPlayer(player: AVPlayer(url: URL(string: videoURL)!))
    }
}
