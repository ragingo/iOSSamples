//
//  Protocols.swift
//  VideoPlayer
//
//  Created by ragingo on 2025/06/15.
//

import Foundation

nonisolated protocol RepositoryProtocol {}

nonisolated protocol HTTPRepositoryProtocol: RepositoryProtocol {
    var urlSession: URLSession { get }
}

extension HTTPRepositoryProtocol {
    static var detaultURLSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return URLSession(configuration: configuration)
    }

    static var defaultUserAgent: String {
        "sample_video_player"
    }

    func makeURLRequest(for url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(Self.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
}
