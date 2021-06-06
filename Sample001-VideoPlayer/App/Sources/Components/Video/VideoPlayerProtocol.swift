//
//  VideoPlayerProtocol.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Combine
import Foundation
import QuartzCore

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

protocol VideoPlayerProtocol: AnyObject {
    var layer: CALayer { get }
    var isPlaying: Bool { get }
    var isBuffering: Bool { get }
    var rate: Float { get set }
    var loadStatusSubject: PassthroughSubject<VideoLoadStatus, Never> { get }
    var playStatusSubject: PassthroughSubject<VideoPlayStatus, Never> { get }
    var durationSubject: PassthroughSubject<Double, Never> { get }
    var positionSubject: PassthroughSubject<Double, Never> { get }
    var isPlaybackLikelyToKeepUpSubject: PassthroughSubject<Bool, Never> { get }

    func prepare()
    func invalidate()
    func open(urlString: String)
    func play()
    func pause()
    func seek(seconds: Double, completion: @escaping (() -> Void))
}
