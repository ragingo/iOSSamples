//
//  CameraDevicePosition.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/15.
//

import AVFoundation

public enum CameraDevicePosition: Sendable {
    case front
    case back
    case unspecified
}

extension AVCaptureDevice.Position {
    init(_ position: CameraDevicePosition) {
        switch position {
        case .front:
            self = .front
        case .back:
            self = .back
        case .unspecified:
            self = .unspecified
        }
    }
}
