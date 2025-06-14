//
//  VideoListViewModel.swift
//  App
//
//  Created by ragingo on 2021/06/08.
//

import Combine
import Foundation

// VideoListView で使う ViewModel
@Observable
final class VideoListViewModel {
    private(set) var videos = [Video]()
    private(set) var isLoading = false

    private let videoRepository: any VideoRepositoryProtocol

    init(
        videoRepository: any VideoRepositoryProtocol = VideoRepository()
    ) {
        self.videoRepository = videoRepository
    }

    func fetchItems() async {
        defer {
            isLoading = false
        }
        isLoading = true

        do {
            videos = try await videoRepository.fetchVideos()
        } catch {
            print(error)
        }
    }
}
