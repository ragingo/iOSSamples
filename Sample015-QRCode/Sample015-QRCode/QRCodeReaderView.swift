//
//  QRCodeReaderView.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/01/26.
//

import UIKit
import AVFoundation
import Combine

class QRCodeReaderView: UIView {
    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let metadataOutputQueue = DispatchQueue(label: "MetadataOutputQueue", qos: .default)

    private let _result = PassthroughSubject<String, Never>()
    let result: AnyPublisher<String, Never>

    override init(frame: CGRect) {
        result = _result
            .removeDuplicates()
            .eraseToAnyPublisher()

        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return false
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return false
        }

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.frame = bounds
        layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer

        captureSession.beginConfiguration()
        captureSession.addInput(deviceInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        } else {
            return false
        }
        metadataOutput.metadataObjectTypes = [.qr]
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataOutputQueue)

        captureSession.commitConfiguration()

        return true
    }

    func start() {
        metadataOutputQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stop() {
        metadataOutputQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}

extension QRCodeReaderView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        metadataObjects
            .compactMap {
                videoPreviewLayer?.transformedMetadataObject(for: $0)
            }
            .compactMap {
                $0 as? AVMetadataMachineReadableCodeObject
            }
            .filter {
                $0.type == .qr
            }
            .compactMap {
                $0.stringValue
            }
            .forEach {
                _result.send($0)
            }
    }
}
