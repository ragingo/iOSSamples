//
//  Permissions.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/15.
//

import AVFoundation

public enum Permissions {}

extension Permissions {
    public static func checkCamera() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}
