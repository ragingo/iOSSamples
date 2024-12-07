//
//  CameraPreview.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/05.
//

import AVFoundation
import Combine
import SwiftUI

struct CameraPreview: View {
    @State private var camera: Camera?
    @State private var layer: CALayer = .init()
    @State private var showNotGrantedAlert = false
    @State private var devices: [AVCaptureDevice] = []
    @State private var commands: AnyPublisher<Command, Never>
    private var onDeviceListLoaded: (([AVCaptureDevice]) -> Void)?
    private var onInitialized: (() -> Void)?

    // SwiftUI で async init を使ってはいけない
    // async init 呼び出し側でコンパイルエラー
    init(commands: AnyPublisher<Command, Never>) {
        self.commands = commands
    }

    var body: some View {
        VStack {
            VideoSurfaceView(playerLayer: layer)
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
            case .empty:
                break
            case .loadDevices(let position):
                devices = Camera.detectDevices(position: position)
                onDeviceListLoaded?(devices)
            case .selectDevice(let device):
                Task {
                    await camera.initializeCamera(device: device)
                }
            case .startCapture:
                Task {
                    if await Camera.isAuthorized(for: .video) {
                        await camera.startCapture()
                    } else {
                        showNotGrantedAlert = true
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
    func onDeviceListLoaded(perform: @Sendable @escaping @MainActor ([AVCaptureDevice]) -> Void) -> Self {
        var newSelf = self
        newSelf.onDeviceListLoaded = perform
        return newSelf
    }
}

extension CameraPreview {
    enum Command: @unchecked Sendable {
        case empty
        case loadDevices(position: AVCaptureDevice.Position = .unspecified)
        case selectDevice(device: AVCaptureDevice)
        case startCapture
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

// async init を使うとプレビューマクロ生成コードでコンパイルエラー
//#Preview {
//    CameraPreview()
//}
