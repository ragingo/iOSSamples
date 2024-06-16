//
//  VideoPlayerProtocol.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Combine
import Foundation
import QuartzCore
import CoreImage
import CoreMedia

enum VideoLoadStatus {
    case unknown
    case readyToPlay
    case failed
}

enum VideoPlayStatus {
    case paused
    case buffering
    case playing
}

protocol VideoPlayerProtocol: AnyObject, Sendable {
    var onAudioSampleBufferUpdate: ((CMSampleBuffer) -> Void)? { get set }
    var layer: CALayer { get }
    var isLiveStreaming: Bool { get }
    var isPlaying: Bool { get }
    var isBuffering: Bool { get }
    var rate: Float { get set }
    var loadStatusSubject: PassthroughSubject<VideoLoadStatus, Never> { get }
    var playStatusSubject: PassthroughSubject<VideoPlayStatus, Never> { get }
    var durationSubject: PassthroughSubject<Double, Never> { get }
    var positionSubject: PassthroughSubject<Double, Never> { get }
    var isPlaybackLikelyToKeepUpSubject: PassthroughSubject<Bool, Never> { get }
    var isSeekingSubject: PassthroughSubject<Bool, Never> { get }
    var loadedBufferRangeSubject: PassthroughSubject<(Double, Double), Never> { get }
    var generatedImageSubject: PassthroughSubject<(Double, CGImage), Never> { get }
    var bandwidthsSubject: PassthroughSubject<[Int], Never> { get }

    func prepare()
    func invalidate()
    func open(urlString: String) async
    func play()
    func pause()
    func seek(seconds: Double)

    func requestGenerateImage(time: Double, size: CGSize)
    func cancelImageGenerationRequests()
    func changePreferredPeakBitRate(value: Int)
    func addFilter(filter: CIFilter)
    func clearFilters()
}
