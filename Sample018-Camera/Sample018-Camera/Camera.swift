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

@MainActor
final class Camera {
    private let captureSession: UncheckedSendableValue<AVCaptureSession> = .init(value: .init())
    private let cameraPreviewLayer: AVCaptureVideoPreviewLayer = .init()

    var previewLayer: CALayer {
        cameraPreviewLayer
    }

    init() {}

    var isAuthorized: Bool {
        get async {
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

    func initializeCamera() -> Bool {
        captureSession.value.beginConfiguration()
        defer {
            captureSession.value.commitConfiguration()
        }

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
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
            .devices

        devices
            .forEach { print($0) }

        guard let videoCaptureDevice = devices.first else {
            print("Failed to get video capture device")
            return false
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return false
        }

        if captureSession.value.canAddInput(videoInput) {
            captureSession.value.addInput(videoInput)
        } else {
            print("Failed to add video input")
            return false
        }

        cameraPreviewLayer.session = captureSession.value
        cameraPreviewLayer.videoGravity = .resizeAspectFill

        return true
    }

    func startPreview() async {
        guard await isAuthorized else { return }
        Task.detached {
            self.captureSession.value.startRunning()
        }
    }

    func pausePreview() {
        captureSession.value.stopRunning()
    }

    func stopPreview() {
        captureSession.value.stopRunning()
    }
}
