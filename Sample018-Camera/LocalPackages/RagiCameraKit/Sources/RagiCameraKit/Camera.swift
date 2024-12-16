//
//  Camera.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/01.
//

import AVFoundation
import Combine
import CoreImage

public actor Camera {
    private let videoPreviewLayer: CameraVideoPreviewLayer = .init()
    private let captureSession: CameraCaptureSession = .init()
    private var devices: [CameraDevice] = []
    // 注意: DispatchSerialQueue のイニシャライザは iOS17.0+ だから、DispatchQueue を使うしかない
    private let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
    private let sampleBufferDelegate = SampleBufferDelegate()
    private let executor = DispatchQueueExecutor(label: "CameraQueue")

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    @MainActor
    public var previewLayer: CALayer {
        videoPreviewLayer
    }

    @MainActor
    public var capturedFrameStream: AsyncStream<CapturedVideoFrame> {
        sampleBufferDelegate.capturedFrameStream
    }

    public init(videoCaptureInterval: TimeInterval = .zero) {
    }

    public func detectDevices(position: CameraDevicePosition = .unspecified) -> [CameraDevice] {
        devices = CameraDevice.detectDevices(position: position)
        return devices
    }

    private func initializeCamera(device: CameraDevice) throws -> Bool {
        guard let device = devices.first(where: { $0 == device }) else { return false }
        device.enableAutoFocus()

        let videoInput = try AVCaptureDeviceInput(device: device.rawDevice)
        let videoOutput = AVCaptureVideoDataOutput()

        captureSession.configure(
            inputs: [videoInput],
            outputs: [videoOutput]
        )

        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
        ] as [String: Any]
        videoOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: sampleBufferQueue)

        if let videoConnection = videoOutput.connection(with: .video) {
            if videoConnection.isVideoMirroringSupported {
                videoConnection.isVideoMirrored = device.rawDevice.position == .front
            }
        }

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

        videoPreviewLayer.connection?.videoOrientation = orientation.videoLayerOrientation
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
