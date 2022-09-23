//
//  RgImage.swift
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/24.
//

import SwiftUI
import UIKit
import Cpp

// https://developer.apple.com/videos/play/wwdc2021/10132/
// https://www.donnywals.com/running-tasks-in-parallel-with-swift-concurrencys-task-groups/
// https://zenn.dev/akkyie/articles/swift-concurrency
struct RgImage {
    struct FetchResult {
        let data: Data
        let type: CppMedia.MediaType
    }

    enum FetchMode {
        case serial
        case parallel
    }

    enum CancellationBehavior {
        case silent
        case throwError
    }

    func fetch(url: URL) async throws -> FetchResult? {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }

        let type: CppMedia.MediaType? = data.withUnsafeBytes { ptr in
            guard let baseAddress = ptr.baseAddress else {
                return nil
            }
            return CppMedia.RgMedia.getType(baseAddress, data.count)
        }

        guard let type else {
            return nil
        }

        return .init(data: data, type: type)
    }

    func fetchAll(
        mode: FetchMode = .serial,
        urls: [URL],
        cancellationBehavior: CancellationBehavior = .silent
    ) async throws -> [URL: FetchResult?] {
        switch mode {
        case .serial:
            return try await fetchAllSerial(urls: urls, cancellationBehavior: cancellationBehavior)
        case .parallel:
            return try await fetchAllParallel(urls: urls, cancellationBehavior: cancellationBehavior)
        }
    }

    private func fetchAllSerial(
        urls: [URL],
        cancellationBehavior: CancellationBehavior = .silent
    ) async throws -> [URL: FetchResult?] {
        var results: [URL: FetchResult?] = [:]

        for url in urls {
            switch cancellationBehavior {
            case .silent:
                if Task.isCancelled {
                    break
                }
            case .throwError:
                try Task.checkCancellation()
            }
            results[url] = try await fetch(url: url)
        }

        return results
    }

    // https://forums.swift.org/t/taskgroup-and-parallelism/51039/22
    // シミュレーターだとうまく並列に動いてくれないらしい。デバイスでも確認する。
    private func fetchAllParallel(
        urls: [URL],
        cancellationBehavior: CancellationBehavior = .silent
    ) async throws -> [URL: FetchResult?] {
        var results: [URL: FetchResult?] = [:]

        let sendable = (URL, FetchResult?).self

        switch cancellationBehavior {
        case .silent:
            await withTaskGroup(of: sendable) { group in
                for url in urls {
                    group.addTask {
                        do {
                            return (url, try await fetch(url: url))
                        } catch {
                            return (url, nil)
                        }
                    }
                }

                for await (url, fetchResult) in group {
                    results[url] = fetchResult
                }
            }
        case .throwError:
            try await withThrowingTaskGroup(of: sendable) { group in
                for url in urls {
                    group.addTask {
                        return (url, try await fetch(url: url))
                    }
                }

                for try await (url, fetchResult) in group {
                    results[url] = fetchResult
                }
            }
        }

        return results
    }
}
