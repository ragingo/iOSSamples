//
//  VideoRepositoryTests.swift
//  AppTests
//
//  Created by ragingo on 2025/06/14.
//

import Foundation
import Testing

@testable import App

@Suite(.serialized)
struct VideoRepositoryTests {
    @Test
    func fetchVideosEmptyResponse() async throws {
        MockVideoRepository.entries = [MockVideoRepository.fetchVideosGetEmptyEntry]
        let repository = VideoRepository(urlSession: makeVideoRepositoryMock())
        let videos = try await repository.fetchVideos()

        #expect(videos == [])
    }

    @Test
    func fetchVideosMultipleResponse() async throws {
        MockVideoRepository.entries = [MockVideoRepository.fetchVideosGetMultipleEntry]
        let repository = VideoRepository(urlSession: makeVideoRepositoryMock())
        let videos = try await repository.fetchVideos()

        #expect(
            videos == [
                Video(id: 1, title: "Sample Video 1", url: "https://example.com/video1.mp4"),
                Video(id: 2, title: "Sample Video 2", url: "https://example.com/video2.mp4")
            ])
    }
}

private func makeVideoRepositoryMock() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockVideoRepository.self]
    return URLSession(configuration: configuration)
}
