//
//  VideoListViewModel.swift
//  App
//
//  Created by ragingo on 2021/06/08.
//

import Combine
import Foundation

struct Video: Identifiable {
    var id: Int
    var title: String
    var url: String
}

// VideoListView で使う ViewModel
final class VideoListViewModel: ObservableObject {
    @Published private(set) var videos = [Video]()

    @MainActor
    func fetchItems() async {
        async {
            // delay
            await Task.sleep(2)

            // samples: https://hls-js.netlify.app/demo/
            let videos = [
                Video(id: 1, title: "sintel", url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
                Video(id: 2, title: "bipbopall 1", url: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"),
                Video(id: 3, title: "bipbopall 2", url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"),
                Video(id: 4, title: "x36xhzz", url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),
                Video(id: 5, title: "test_001", url: "https://test-streams.mux.dev/test_001/stream.m3u8")
            ]

            self.videos = videos
        }
    }
}
