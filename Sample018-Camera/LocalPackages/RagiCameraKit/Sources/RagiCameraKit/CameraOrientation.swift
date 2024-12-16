//
//  CameraOrientation.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/16.
//

import AVFoundation
import UIKit

public enum CameraOrientation: Sendable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight

    var videoLayerOrientation: AVCaptureVideoOrientation {
        AVCaptureVideoOrientation(self)
    }
}

extension CameraOrientation {
    public init?(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        case .faceUp, .faceDown, .unknown:
            return nil
        default:
            return nil
        }
    }
}

extension AVCaptureVideoOrientation {
    init(_ orientation: CameraOrientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        }
    }
}
