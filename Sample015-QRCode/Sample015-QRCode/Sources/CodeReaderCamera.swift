//
//  CodeReaderCamera.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/01/29.
//

import AVFoundation

protocol CodeReaderCameraDelegate: AnyObject {
    func codeReaderCamera(_ camera: CodeReaderCamera, didDetectCode code: String)
    func codeReaderCamera(_ camera: CodeReaderCamera, didUpdateCorners corners: [CGPoint])
    func codeReaderCamera(_ camera: CodeReaderCamera, pixelBuffer: CVPixelBuffer)
}

class CodeReaderCamera: NSObject {
    private(set) var captureSession = AVCaptureSession()
    private let metadataOutputQueue = DispatchQueue(label: "MetadataOutputQueue", qos: .default)
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", qos: .default)
    private(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    weak var delegate: CodeReaderCameraDelegate?
    let metadataOutput = AVCaptureMetadataOutput()
    let videoDataOutput = AVCaptureVideoDataOutput()

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

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspect

        metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8]
        if #available(iOS 15.4, *) {
            metadataOutput.metadataObjectTypes += [.microQR]
        }
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataOutputQueue)

        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
        ] as [String: Any]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

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

extension CodeReaderCamera: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            guard let readableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }

            if let value = readableCodeObject.stringValue {
                delegate?.codeReaderCamera(self, didDetectCode: value)
            }

            delegate?.codeReaderCamera(self, didUpdateCorners: readableCodeObject.corners)
        }
    }
}

extension CodeReaderCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        // portrait 固定で実験
//        connection.videoOrientation = .portrait
        delegate?.codeReaderCamera(self, pixelBuffer: pixelBuffer)
    }
}
