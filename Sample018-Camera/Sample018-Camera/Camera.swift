//
//  Camera.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/01.
//

import AVFoundation

@globalActor
actor CameraActor {
    static let shared = CameraActor()
}

@CameraActor
private final class CameraCaptureSession {
    private(set) var session: AVCaptureSession = .init()

    func configure(inputs: [AVCaptureDeviceInput] = []) {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }

        inputs.forEach { input in
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                print("Failed to add input: \(input)")
            }
        }
    }

    func start() {
        session.startRunning()
    }

    func pause() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            session.connections.forEach { session.removeConnection($0) }
            if #available(iOS 18.0, *) {
                session.controls.forEach { session.removeControl($0) }
            }
        }
    }
}

@CameraActor
final class CameraVideoPreviewLayer: AVCaptureVideoPreviewLayer {
}
extension CameraVideoPreviewLayer: @unchecked Sendable {}

@CameraActor
final class Camera {
    private let videoPreviewLayer: CameraVideoPreviewLayer = .init()
    private let captureSession: CameraCaptureSession = .init()

    @MainActor
    var previewLayer: CALayer {
        videoPreviewLayer
    }

    static func isAuthorized(for mediaType: AVMediaType) async -> Bool {
        assert(mediaType == .video || mediaType == .audio)
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: mediaType)
        default:
            return false
        }
    }

    nonisolated static func detectDevices(position: AVCaptureDevice.Position = .unspecified) -> sending [AVCaptureDevice] {
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
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: position)
            .devices

        devices
            .forEach { print($0) }

        if devices.isEmpty {
            print("No camera devices found")
        }

        return devices
    }

    func initializeCamera(device: AVCaptureDevice) -> Bool {
        if device.isFocusModeSupported(.continuousAutoFocus) {
            try? device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("Failed to create video input: \(error)")
            return false
        }

        captureSession.configure(inputs: [videoInput])

        videoPreviewLayer.session = captureSession.session
        videoPreviewLayer.videoGravity = .resizeAspectFill

        return true
    }

    func startCapture() {
        captureSession.start()
    }

    func pauseCapture() {
        captureSession.pause()
    }

    func stopCapture() {
        captureSession.stop()
    }
}
