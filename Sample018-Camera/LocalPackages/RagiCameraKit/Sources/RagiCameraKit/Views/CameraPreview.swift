//
//  CameraPreview.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/05.
//

import Combine
import SwiftUI

public struct CameraPreview: View {
    @State private var camera = Camera(videoCaptureInterval: 3)
    @State private var showNotGrantedAlert = false
    @State private var devices: [CameraDevice] = []
    @State private var commands: AnyPublisher<Command, Never>
    @State private var lastCommand: Command?
    private let handlers = Handlers()
    @State private var observeCapturedFrameStreamTask: Task<Void, Never>?

    public init(commands: AnyPublisher<Command, Never>) {
        self.commands = commands
    }

    public var body: some View {
        VideoSurfaceView(playerLayer: camera.previewLayer)
            .task {
                handlers.onInitialized?()
                observeCapturedFrameStream()
            }
            .task(id: lastCommand) {
                guard let lastCommand else { return }

                switch lastCommand {
                case .loadDevices(let position):
                    devices = await camera.detectDevices(position: position)
                    handlers.onDeviceListLoaded?(devices)
                case .startCapture(let device):
                    await onStartCapture(device: device)
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
            .onDisappear {
                observeCapturedFrameStreamTask?.cancel()
            }
    }

    private func onStartCapture(device: CameraDevice) async {
        guard await Permissions.checkCamera() else {
            showNotGrantedAlert = true
            return
        }
        do {
            // task は nonisolated だから actor 型のメソッドやアクター隔離されたクラスは協調スレッドプールで実行される
            // Thread 2 Queue : com.apple.root.user-initiated-qos.cooperative (concurrent)
            //
            // その後 actor に unownedExecutor を用意することで、特定キュー(serialなら特定スレッド)で動作させることができる
            // Thread 9 Queue : CameraQueue (serial)
            try await camera.startCapture(device: device)
        } catch {
            print(error)
        }
    }

    private func observeCapturedFrameStream() {
        if let observeCapturedFrameStreamTask {
            if !observeCapturedFrameStreamTask.isCancelled {
                observeCapturedFrameStreamTask.cancel()
            }
        }
        observeCapturedFrameStreamTask = Task {
            for await frame in camera.capturedFrameStream {
                handlers.onCapturedFrameUpdated?(frame)
            }
        }
    }
}

extension CameraPreview {
    private final class Handlers {
        var onInitialized: (() -> Void)?
        var onDeviceListLoaded: (([CameraDevice]) -> Void)?
        var onCapturedFrameUpdated: ((CapturedVideoFrame) -> Void)?
    }

    public func onInitialized(perform: @Sendable @escaping @MainActor () -> Void) -> Self {
        handlers.onInitialized = perform
        return self
    }

    public func onDeviceListLoaded(perform: @Sendable @escaping @MainActor ([CameraDevice]) -> Void) -> Self {
        handlers.onDeviceListLoaded = perform
        return self
    }

    public func onCapturedFrameUpdated(perform: @Sendable @escaping @MainActor (CapturedVideoFrame) -> Void) -> Self {
        handlers.onCapturedFrameUpdated = perform
        return self
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
