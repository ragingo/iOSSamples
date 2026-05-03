//
//  ImageGenerator.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import AVFoundation
import Foundation

actor ImageGenerator: Sendable {
    private let imageGenerator: AVAssetImageGenerator
    private var cache: [Double: CGImage] = [:]

    init(asset: AVAsset) {
        imageGenerator = .init(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
    }

    func generateImage(time: Double, size: CGSize) async throws -> (Double, CGImage) {
        if let image = cache[time] {
            return (time, image)
        }

        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let (image, time) = try await imageGenerator.__generateCGImage(for: cmTime)
        return (time.seconds, image)
    }

    func generateImages(times: [Double], size: CGSize) async throws -> [Double: CGImage] {
        imageGenerator.maximumSize = size

        return try await withThrowingTaskGroup(of: (Double, CGImage?).self) { group in
            var result: [Double: CGImage] = [:]
            for time in times {
                group.addTask(name: "\(type(of: self))", priority: .background) { [weak self] in
                    guard let self else { return (time, nil) }
                    return try await generateImage(time: time, size: size)
                }
            }
            for try await (time, image) in group {
                result[time] = image
            }
            cache.merge(result) { $1 }
            return result
        }
    }

    func cancel() {
        imageGenerator.cancelAllCGImageGeneration()
    }
}
