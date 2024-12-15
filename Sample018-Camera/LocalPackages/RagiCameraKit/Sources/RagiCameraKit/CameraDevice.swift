//
//  CameraDevice.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/15.
//

import AVFoundation

public class CameraDevice: Identifiable, Equatable, @unchecked Sendable {
    public var id: String {
        rawDevice.uniqueID
    }

    public var localizedName: String {
        rawDevice.localizedName
    }

    let rawDevice: AVCaptureDevice

    func enableAutoFocus() {
        if rawDevice.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try rawDevice.lockForConfiguration()
                rawDevice.focusMode = .continuousAutoFocus
                rawDevice.unlockForConfiguration()
            } catch {
                // 重要ではないからログを残すのみとする
                print("Failed to set focus mode: \(error)")
            }
        }
    }

    init(rawDevice: AVCaptureDevice) {
        self.rawDevice = rawDevice
    }

    public static func == (lhs: CameraDevice, rhs: CameraDevice) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CameraDevice {
    public static func detectDevices(position: CameraDevicePosition = .unspecified) -> [CameraDevice] {
        let deviceTypes: [AVCaptureDevice.DeviceType]
#if os(macOS)
        deviceTypes = [.builtInWideAngleCamera, .continuityCamera, .deskViewCamera, .external]
#elseif os(iOS)
        if #available(iOS 17.0, *) {
            deviceTypes = [.builtInWideAngleCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInUltraWideCamera, .continuityCamera, .external]
        } else {
            deviceTypes = [.builtInWideAngleCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInUltraWideCamera]
        }
#else
        deviceTypes = [.builtInWideAngleCamera]
#endif
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .init(position))
        let devices = session.devices
            .filter { $0.isConnected }
            .filter { !$0.isSuspended }

        return devices.map {
            CameraDevice(rawDevice: $0)
        }
    }
}
