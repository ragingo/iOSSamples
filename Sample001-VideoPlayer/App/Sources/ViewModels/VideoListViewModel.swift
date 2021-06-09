//
//  VideoListViewModel.swift
//  App
//
//  Created by ragingo on 2021/06/08.
//

import Combine
import Foundation

private let jsonFileURL = "https://raw.githubusercontent.com/ragingo/iOSSamples/main/Sample001-VideoPlayer/SampleData/videos.json"

// VideoListView で使う ViewModel
final class VideoListViewModel: ObservableObject {
    @Published private(set) var videos = [Video]()
    @Published private(set) var isLoading = false

    @MainActor
    func fetchItems() async {
        defer {
            isLoading = false
        }
        isLoading = true

        guard let url = URL(string: jsonFileURL) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("sample_video_player", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let response = try decoder.decode(VideosResponse.self, from: data)
            videos = response.videos
        } catch {
            print(error)
        }
    }
}
