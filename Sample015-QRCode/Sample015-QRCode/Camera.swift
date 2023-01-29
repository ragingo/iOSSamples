//
//  Camera.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/01/29.
//

import AVFoundation

class Camera {
    let metadataOutput = AVCaptureMetadataOutput()
    let videoDataOutput = AVCaptureVideoDataOutput()
    private(set) var captureSession = AVCaptureSession()

    init() {
    }

    func prepare() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return false
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return false
        }

        guard captureSession.canAddInput(deviceInput) else {
            return false
        }
        guard captureSession.canAddOutput(metadataOutput) else {
            return false
        }
        guard captureSession.canAddOutput(videoDataOutput) else {
            return false
        }

        captureSession.beginConfiguration()
        captureSession.addInput(deviceInput)
        captureSession.addOutput(metadataOutput)
        captureSession.addOutput(videoDataOutput)
        captureSession.commitConfiguration()

        return true
    }

    func startCapture() {
        Task { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopCapture() {
        Task { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}
