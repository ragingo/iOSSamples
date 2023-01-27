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
    private let trackingFrame = UIView()

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

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = bounds
    }

    func configure() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return false
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return false
        }

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = bounds
        layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer

        trackingFrame.layer.borderWidth = 4
        trackingFrame.layer.borderColor = UIColor.systemYellow.cgColor
        trackingFrame.frame = .zero
        addSubview(trackingFrame)

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

    private func updateTrackingFrame(_ bounds: CGRect) {
        DispatchQueue.main.async { [weak self] in
            self?.trackingFrame.frame = bounds
        }
    }
}

extension QRCodeReaderView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        guard let videoPreviewLayer else { return }

        for metadataObject in metadataObjects {
            guard let transformedObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject) else {
                continue
            }

            guard let readableCodeObject = transformedObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }

            if readableCodeObject.type != .qr {
                continue
            }

            if let value = readableCodeObject.stringValue {
                _result.send(value)
            }

            updateTrackingFrame(readableCodeObject.bounds)
        }
    }
}
