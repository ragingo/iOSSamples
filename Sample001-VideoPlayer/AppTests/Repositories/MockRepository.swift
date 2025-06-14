//
//  MockRepository.swift
//  VideoPlayer
//
//  Created by ragingo on 2025/06/14.
//

import Foundation

class MockRepository: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func stopLoading() {
    }

    open var baseURL: URL {
        URL(string: "https://localhost")!
    }

    func buildURL(for path: String) -> URL {
        baseURL.appendingPathComponent(path)
    }
}

extension MockRepository {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    struct Request: Hashable {
        var method: HTTPMethod
        var path: String
    }

    struct Response: Hashable {
        var statusCode: Int
        var data: Data
    }

    struct MockEntry: Hashable {
        var request: Request
        var response: Response
    }
}
