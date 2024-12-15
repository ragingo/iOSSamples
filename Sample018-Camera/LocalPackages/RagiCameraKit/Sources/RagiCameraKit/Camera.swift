//
//  Camera.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/01.
//

import AVFoundation
import Combine
import CoreImage

// DispatchSerialQueue のイニシャライザは iOS17.0+
// DispatchSerialQueue の asUnownedSerialExecutor() が使えないから、
// 自分で SerialExecutor を実装する必要あり
final class CameraExecutor: SerialExecutor {
    private let cameraQueue = DispatchQueue(label: "CameraQueue")

    func enqueue(_ job: UnownedJob) {
        let executor = asUnownedSerialExecutor()
        cameraQueue.async {
            job.runSynchronously(on: executor)
        }
    }

    // 注意: asUnownedSerialExecutor() のデフォルト実装が使えるのは iOS17.0+
    // 参考: https://github.com/swiftlang/swift/blob/dda7c8139646395fa09b01fea4cefc65862b8cf8/stdlib/public/Concurrency/Executor.swift#L291-L296
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

public actor Camera {
    private let videoPreviewLayer: CameraVideoPreviewLayer = .init()
    private let captureSession: CameraCaptureSession = .init()
    private var devices: [AVCaptureDevice] = []
    private let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
    private let sampleBufferDelegate: SampleBufferDelegate

    // 注意: DispatchSerialQueue のイニシャライザは iOS17.0+
    private let videoOutputQueue = DispatchQueue(label: "VideoOutputQueue")

    private let executor = CameraExecutor()

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    @MainActor
    public var previewLayer: CALayer {
        videoPreviewLayer
    }

    public var capturedFrameStream: AsyncStream<CapturedVideoFrame> {
        sampleBufferDelegate.capturedFrameStream
    }

    public init(videoCaptureInterval: TimeInterval = .zero) {
        sampleBufferDelegate = SampleBufferDelegate()
    }

    public static func isAuthorized() async -> Bool {
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

    public func detectDevices(position: CameraDevicePosition = .unspecified) -> [CameraDevice] {
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
        let videoOutput = AVCaptureVideoDataOutput()

        captureSession.configure(
            inputs: [videoInput],
            outputs: [videoOutput]
        )

        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
        ] as [String: Any]
        videoOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: sampleBufferQueue)

        videoPreviewLayer.session = captureSession.session
        videoPreviewLayer.videoGravity = .resizeAspectFill

        return true
    }

    public func startCapture(device: CameraDevice, orientation: CameraOrientation = .portrait) throws {
        if captureSession.session.isRunning {
            stopCapture()
        }
        guard try initializeCamera(device: device) else {
            return
        }
        changeOrientation(orientation: orientation)
        captureSession.start()
    }

    public func pauseCapture() {
        captureSession.pause()
    }

    public func stopCapture() {
        captureSession.stop()
    }

    public func changeOrientation(orientation: CameraOrientation) {
        captureSession.changeOrientation(orientation: orientation)
    }
}

public struct CameraDevice: Identifiable, Hashable, Sendable {
    public var id: String
    public var localizedName: String

    public init(id: String, localizedName: String) {
        self.id = id
        self.localizedName = localizedName
    }
}

public enum CameraDevicePosition: Sendable {
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

extension Camera {
    private final class SampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
        private let ciContext = CIContext()
        private let stream = AsyncStream.makeStream(of: CapturedVideoFrame.self)
        var capturedFrameStream: AsyncStream<CapturedVideoFrame> {
            stream.stream
        }

        nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            stream.continuation.yield(CapturedVideoFrame(ciContext: ciContext, rawBuffer: sampleBuffer))
        }
    }
}
