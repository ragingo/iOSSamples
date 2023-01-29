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
    private let camera: Camera
    private let metadataOutputQueue = DispatchQueue(label: "MetadataOutputQueue", qos: .default)
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", qos: .default)

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let trackingFrame = UIView()

    private let _result = PassthroughSubject<String, Never>()
    let result: AnyPublisher<String, Never>

    override init(frame: CGRect) {
        camera = .init()
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
        guard camera.prepare() else {
            return false
        }

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: camera.captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = bounds
        layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer

        trackingFrame.layer.borderWidth = 4
        trackingFrame.layer.borderColor = UIColor.systemYellow.cgColor
        trackingFrame.frame = .zero
        addSubview(trackingFrame)

        camera.metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8]
        if #available(iOS 15.4, *) {
            camera.metadataOutput.metadataObjectTypes += [.microQR]
        }
        camera.metadataOutput.setMetadataObjectsDelegate(self, queue: metadataOutputQueue)
        camera.videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        return true
    }

    func start() {
        camera.startCapture()
    }

    func stop() {
        camera.stopCapture()
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

            if let value = readableCodeObject.stringValue {
                _result.send(value)
            }

            updateTrackingFrame(readableCodeObject.bounds)
        }
    }
}

extension QRCodeReaderView: AVCaptureVideoDataOutputSampleBufferDelegate {
}
