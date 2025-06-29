//
//  VideoRepository.swift
//  App
//
//  Created by ragingo on 2025/06/14.
//

import Foundation

nonisolated protocol VideoRepositoryProtocol: HTTPRepositoryProtocol {
    func fetchVideos() async throws -> [Video]
}

nonisolated final class VideoRepository: VideoRepositoryProtocol {
    let urlSession: URLSession

    private static let apiBaseURL = URL(string: "https://raw.githubusercontent.com/ragingo/iOSSamples/main/Sample001-VideoPlayer/SampleData/")!

    init(urlSession: URLSession = detaultURLSession) {
        self.urlSession = urlSession
    }

    @concurrent func fetchVideos() async throws -> [Video] {
        let request = makeURLRequest(for: Self.apiBaseURL.appendingPathComponent("videos.json"))
        let response: VideosResponse = try await RestAPIClient(urlSession: urlSession).fetch(from: request)
        return response.videos
    }
}
