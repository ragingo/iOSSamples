//
//  Camera.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/01.
//

import AVFoundation

struct UncheckedSendableValue<T>: @unchecked Sendable {
    var value: T
}

// TODO: これを消してもコンパイルが通るようにする
extension AVCaptureSession: @retroactive @unchecked Sendable {}

@globalActor
actor CameraActor {
    static let shared = CameraActor()
}

@CameraActor
class CameraCaptureSession {
    var value: AVCaptureSession = .init()
}

@CameraActor
final class Camera {
    private var captureSession: CameraCaptureSession = .init()
//    private let captureSession: CameraCaptureSession = .init()

    @MainActor
    private let cameraPreviewLayer: AVCaptureVideoPreviewLayer = .init()

    @MainActor
    var previewLayer: CALayer {
        cameraPreviewLayer
    }

    nonisolated init() {}

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

    @MainActor
    func initializeCamera(device: AVCaptureDevice) async -> Bool {
        await captureSession.value.beginConfiguration()

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
            await captureSession.value.commitConfiguration()
            return false
        }

        if await captureSession.value.canAddInput(videoInput) {
            await captureSession.value.addInput(videoInput)
        } else {
            print("Failed to add video input")
            await captureSession.value.commitConfiguration()
            return false
        }

        await captureSession.value.commitConfiguration()

        cameraPreviewLayer.session = await captureSession.value
        cameraPreviewLayer.videoGravity = .resizeAspectFill

        return true
    }

    func startCapture() {
        captureSession.value.startRunning()
    }

    func pauseCapture() {
        if captureSession.value.isRunning {
            captureSession.value.stopRunning()
        }
    }

    func stopCapture() {
        if captureSession.value.isRunning {
            captureSession.value.stopRunning()
            captureSession = .init()
        }
    }
}
