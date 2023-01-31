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
    private let camera: CodeReaderCamera

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

    deinit {
        stop()
        camera.videoPreviewLayer?.removeFromSuperlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        camera.videoPreviewLayer?.frame = bounds
    }

    func configure() -> Bool {
        camera.delegate = self

        guard camera.prepare() else {
            return false
        }

        guard let videoPreviewLayer = camera.videoPreviewLayer else {
            return false
        }
        videoPreviewLayer.frame = bounds
        layer.addSublayer(videoPreviewLayer)

        trackingFrame.layer.borderWidth = 4
        trackingFrame.layer.borderColor = UIColor.systemYellow.cgColor
        trackingFrame.frame = .zero
        addSubview(trackingFrame)

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

extension QRCodeReaderView: CodeReaderCameraDelegate {
    func codeReaderCamera(_ camera: CodeReaderCamera, didUpdateBounds: CGRect) {
        updateTrackingFrame(didUpdateBounds)
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didDetectCode: String) {
        _result.send(didDetectCode)
    }
}
