//
//  CameraCaptureSession.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/12.
//

import AVFoundation

final class CameraCaptureSession {
    private(set) var session: AVCaptureSession = .init()

    func configure(
        inputs: [AVCaptureDeviceInput] = [],
        outputs: [AVCaptureOutput] = []
    ) {
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

        outputs.forEach { output in
            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                print("Failed to add output: \(output)")
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

    func changeOrientation(orientation: CameraOrientation) {
        session.connections
            .compactMap { $0.output }
            .compactMap { $0.connection(with: .video) }
            .forEach { $0.videoOrientation = .init(orientation) }
    }
}

public enum CameraOrientation: Sendable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
}

private extension AVCaptureVideoOrientation {
    init(_ orientation: CameraOrientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        }
    }
}
