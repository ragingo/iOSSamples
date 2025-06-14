//
//  VideoRepository.swift
//  App
//
//  Created by ragingo on 2025/06/14.
//

import Foundation

nonisolated protocol VideoRepositoryProtocol {
    func fetchVideos() async throws -> [Video]
}

nonisolated final class VideoRepository: VideoRepositoryProtocol {
    // swiftlint:disable:next line_length
    private static let apiURL = URL(string: "https://raw.githubusercontent.com/ragingo/iOSSamples/main/Sample001-VideoPlayer/SampleData/videos.json")!

    @concurrent func fetchVideos() async throws -> [Video] {
        var request = URLRequest(url: Self.apiURL)
        request.httpMethod = "GET"
        request.setValue("sample_video_player", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(VideosResponse.self, from: data)
        return response.videos
    }
}
