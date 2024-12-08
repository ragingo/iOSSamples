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

struct CameraDevice: Identifiable, Hashable {
    var id: String
    var localizedName: String
}

enum CameraDevicePosition {
    case front
    case back
    case unspecified
}

private extension AVCaptureDevice.Position {
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

@CameraActor
final class Camera {
    private let videoPreviewLayer: CameraVideoPreviewLayer = .init()
    private let captureSession: CameraCaptureSession = .init()
    private var devices: [AVCaptureDevice] = []

    @MainActor
    var previewLayer: CALayer {
        videoPreviewLayer
    }

    static func isAuthorized() async -> Bool {
        await isAuthorized(for: .video)
    }

    private static func isAuthorized(for mediaType: AVMediaType) async -> Bool {
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

    func detectDevices(position: CameraDevicePosition = .unspecified) -> [CameraDevice] {
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
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .init(position))
            .devices

        self.devices = devices

        return devices.map {
            CameraDevice(id: $0.uniqueID, localizedName: $0.localizedName)
        }
    }

    private func initializeCamera(device: CameraDevice) throws -> Bool {
        guard let device = devices.first(where: { $0.uniqueID == device.id }) else { return false }

        if device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            } catch {
                // 重要ではないからログを残すのみとする
                print("Failed to set focus mode: \(error)")
            }
        }

        let videoInput = try AVCaptureDeviceInput(device: device)

        captureSession.configure(inputs: [videoInput])

        videoPreviewLayer.session = captureSession.session
        videoPreviewLayer.videoGravity = .resizeAspectFill

        return true
    }

    func startCapture(device: CameraDevice) throws {
        if captureSession.session.isRunning {
            stopCapture()
        }
        guard try initializeCamera(device: device) else {
            return
        }
        captureSession.start()
    }

    func pauseCapture() {
        captureSession.pause()
    }

    func stopCapture() {
        captureSession.stop()
    }
}
