//
//  VideoPlayerProtocol.swift
//  App
//
//  Created by ragingo on 2021/06/04.
//

import Combine
import Foundation
import QuartzCore

protocol VideoPlayerProtocol: AnyObject {
    var layer: CALayer { get }
    var isPlaying: Bool { get }
    var isBuffering: Bool { get }
    var rate: Float { get set }
    var durationSubject: PassthroughSubject<Double, Never> { get }
    var positionSubject: PassthroughSubject<Double, Never> { get }

    func prepare()
    func open(urlString: String)
    func play()
    func pause()
    func seek(seconds: Double, completion: @escaping (() -> Void))
}
