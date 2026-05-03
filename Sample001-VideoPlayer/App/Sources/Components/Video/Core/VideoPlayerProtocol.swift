//
//  VideoPlayerProtocol.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Combine
import CoreImage
import CoreMedia
import Foundation
import QuartzCore

struct VideoBufferRange: Equatable {
    let start: Double
    let end: Double

    static let zero = VideoBufferRange(start: .zero, end: .zero)
}

struct VideoSeekThumbnail: Equatable {
    let time: Double
    let image: CGImage
}

@Observable
final class VideoPlayerState {
    var isReady: Bool = false
    var isPlaying: Bool = false
    var isBuffering: Bool = false
    var isSeeking: Bool = false
    var videoQualities: [Int] = []
    var duration: Double = .zero
    var position: Double = .zero
    var loadedBufferRange: VideoBufferRange = .zero
    var seekThumbnail: VideoSeekThumbnail?
}

@MainActor
protocol VideoPlayerProtocol: AnyObject {
    var layer: CALayer { get }
    var rate: Float { get set }
    var state: VideoPlayerState { get }

    func prepare()
    func invalidate()
    func open(urlString: String) async
    func play()
    func pause()
    func seek(seconds: Double) async

    func requestGenerateImage(time: Double, size: CGSize)
    func cancelImageGenerationRequests()
    func changePreferredPeakBitRate(value: Int)
    func addFilter(filter: CIFilter)
    func clearFilters()
}
