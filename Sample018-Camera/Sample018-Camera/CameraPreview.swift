//
//  CameraPreview.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/05.
//

import Combine
import SwiftUI

struct CameraPreview: View {
    @State private var camera: Camera?
    @State private var layer: CALayer?
    @State private var showNotGrantedAlert = false
    @State private var devices: [CameraDevice] = []
    @State private var commands: AnyPublisher<Command, Never>
    private var onInitialized: (() -> Void)?
    private var onDeviceListLoaded: (([CameraDevice]) -> Void)?

    init(commands: AnyPublisher<Command, Never>) {
        self.commands = commands
    }

    var body: some View {
        VStack {
            if let layer {
                VideoSurfaceView(playerLayer: layer)
            } else {
                Color.gray
            }
        }
        .task {
            let camera = await Camera()
            self.camera = camera
            layer = camera.previewLayer
            onInitialized?()
        }
        .onReceive(commands) { command in
            guard let camera else { return }

            switch command {
            case .loadDevices(let position):
                Task {
                    devices = await camera.detectDevices(position: position)
                    onDeviceListLoaded?(devices)
                }
            case .startCapture(let device):
                Task {
                    guard await Camera.isAuthorized() else {
                        showNotGrantedAlert = true
                        return
                    }
                    do {
                        try await camera.startCapture(device: device)
                    } catch {
                        print(error)
                    }
                }
            case .pauseCapture:
                Task {
                    await camera.pauseCapture()
                }
            case .stopCapture:
                Task {
                    await camera.stopCapture()
                }
            }
        }
        .alert("カメラが許可されていません", isPresented: $showNotGrantedAlert) {
            Button("OSの設定画面を開く") {
                openSystemSettings()
            }
        }
    }
}

extension CameraPreview {
    @discardableResult
    func onInitialized(perform: @Sendable @escaping @MainActor () -> Void) -> Self {
        var newSelf = self
        newSelf.onInitialized = perform
        return newSelf
    }

    @discardableResult
    func onDeviceListLoaded(perform: @Sendable @escaping @MainActor ([CameraDevice]) -> Void) -> Self {
        var newSelf = self
        newSelf.onDeviceListLoaded = perform
        return newSelf
    }
}

extension CameraPreview {
    enum Command: @unchecked Sendable {
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
