//
//  CameraPreview.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/05.
//

import Combine
import SwiftUI

public struct CameraPreview: View {
    @State private var camera: Camera?
    @State private var layer: CALayer?
    @State private var showNotGrantedAlert = false
    @State private var devices: [CameraDevice] = []
    @State private var commands: AnyPublisher<Command, Never>
    @State private var lastCommand: Command?
    @State private var snapshot: CGImage?

    private var onInitialized: (() -> Void)?
    private var onDeviceListLoaded: (([CameraDevice]) -> Void)?

    public init(commands: AnyPublisher<Command, Never>) {
        self.commands = commands
    }

    public var body: some View {
        VStack {
            if let layer {
                VideoSurfaceView(playerLayer: layer)
            } else {
                Color.gray
            }
            // キャプチャ画像表示例
            //captureImage
        }
        .task {
            let camera = await Camera(videoCaptureInterval: 3)
            self.camera = camera
            layer = camera.previewLayer
            await Task { @CameraActor in
                camera.onVideoFrameCaptured = onVideoFrameCaptured(_:)
            }.value
            onInitialized?()
        }
        .task(id: lastCommand) {
            guard let camera, let lastCommand else { return }

            switch lastCommand {
            case .loadDevices(let position):
                devices = await camera.detectDevices(position: position)
                onDeviceListLoaded?(devices)
            case .startCapture(let device):
                guard await Camera.isAuthorized() else {
                    showNotGrantedAlert = true
                    return
                }
                do {
                    try await camera.startCapture(device: device)
                } catch {
                    print(error)
                }
            case .pauseCapture:
                await camera.pauseCapture()
            case .stopCapture:
                await camera.stopCapture()
            }
        }
        .onReceive(commands) { command in
            lastCommand = command
        }
        .alert("カメラが許可されていません", isPresented: $showNotGrantedAlert) {
            Button("OSの設定画面を開く") {
                openSystemSettings()
            }
        }
    }

    private func onVideoFrameCaptured(_ frame: CapturedVideoFrame) {
        MainActor.assumeIsolated {
            snapshot = frame.cgImage
        }
    }

    @ViewBuilder
    private var captureImage: some View {
        if let snapshot {
            Image(decorative: snapshot, scale: 1.0)
                .resizable()
                .scaledToFill()
        }
    }
}

extension CameraPreview {
    @discardableResult
    public func onInitialized(perform: @Sendable @escaping @MainActor () -> Void) -> Self {
        var newSelf = self
        newSelf.onInitialized = perform
        return newSelf
    }

    @discardableResult
    public func onDeviceListLoaded(perform: @Sendable @escaping @MainActor ([CameraDevice]) -> Void) -> Self {
        var newSelf = self
        newSelf.onDeviceListLoaded = perform
        return newSelf
    }
}

extension CameraPreview {
    public enum Command: Equatable, @unchecked Sendable {
        case loadDevices(position: CameraDevicePosition = .unspecified)
        case startCapture(device: CameraDevice)
        case pauseCapture
        case stopCapture
    }
}

@MainActor
private func openSystemSettings() {
#if os(iOS)
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
#elseif os(macOS)
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
        NSWorkspace.shared.open(url)
    }
#endif
}
