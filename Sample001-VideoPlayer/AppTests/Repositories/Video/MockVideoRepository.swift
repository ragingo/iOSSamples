//
//  MockVideoRepository.swift
//  VideoPlayer
//
//  Created by ragingo on 2025/06/14.
//

import Foundation

final class MockVideoRepository: MockRepository {
    static var entries: [MockRepository.MockEntry] = []

    override func startLoading() {
        defer {
            client?.urlProtocolDidFinishLoading(self)
        }

        guard let requestURL = request.url else { return }
        guard let entry = findEntry(for: request) else { return }

        let urlResponse = HTTPURLResponse(
            url: requestURL,
            statusCode: entry.response.statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        guard let urlResponse else { return }

        client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: entry.response.data)
    }

    private func findEntry(for request: URLRequest) -> MockRepository.MockEntry? {
        return Self.entries.first { entry in
            entry.request.method.rawValue == request.httpMethod
                && request.url?.absoluteString.hasSuffix(entry.request.path) == true
        }
    }
}

extension MockVideoRepository {
    static let fetchVideosGetEmptyEntry = MockRepository.MockEntry(
        request: .init(method: .get, path: "videos.json"),
        response: .init(statusCode: 200, data: Response.empty.data(using: .utf8)!)
    )

    static let fetchVideosGetMultipleEntry = MockRepository.MockEntry(
        request: .init(method: .get, path: "videos.json"),
        response: .init(statusCode: 200, data: Response.multiple.data(using: .utf8)!)
    )
}

extension MockVideoRepository {
    enum Response {
        static let empty = """
            {
                "videos": []
            }
            """

        static let multiple = """
            {
                "videos": [
                    { "id": 1, "title": "Sample Video 1", "url": "https://example.com/video1.mp4" },
                    { "id": 2, "title": "Sample Video 2", "url": "https://example.com/video2.mp4" }
                ]
            }
            """
    }
}
