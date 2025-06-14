//
//  RestAPIClient.swift
//  VideoPlayer
//
//  Created by ragingo on 2025/06/15.
//

import Foundation

nonisolated final class RestAPIClient {
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (data, _) = try await urlSession.data(from: url)
        return try Self.jsonDecoder.decode(T.self, from: data)
    }

    func fetch<T: Decodable>(from urlRequest: URLRequest) async throws -> T {
        let (data, _) = try await urlSession.data(for: urlRequest)
        return try Self.jsonDecoder.decode(T.self, from: data)
    }
}
