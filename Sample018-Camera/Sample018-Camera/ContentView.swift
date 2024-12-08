//
//  ContentView.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/11/30.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State private var devices: [CameraDevice] = []
    @State private var selectedDevice: CameraDevice?
    @State private var selectedDevicePosition: CameraDevicePosition = .unspecified
    @State private var isCameraCapturing = false

    private let cameraCommands = PassthroughSubject<CameraPreview.Command, Never>()

    var body: some View {
        VStack {
            cameraController

            CameraPreview(commands: cameraCommands.eraseToAnyPublisher())
                .onInitialized {
                    cameraCommands.send(.loadDevices(position: selectedDevicePosition))
                }
                .onDeviceListLoaded { devices in
                    self.devices = devices.sorted { $0.localizedName < $1.localizedName }
                    selectedDevice = self.devices.first
                }
                .frame(width: 300, height: 300)
                .clipped()
                .border(.red)
        }
        .padding()
        .onChange(of: selectedDevice) { _ in
            guard let selectedDevice else {
                return
            }
            // SwiftUI Preview 動作時はデバイスを選択しない
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }
            cameraCommands.send(.startCapture(device: selectedDevice))
            isCameraCapturing = true
        }
        .onChange(of: selectedDevicePosition) { _ in
            cameraCommands.send(.loadDevices(position: selectedDevicePosition))
        }
        .onDisappear {
            cameraCommands.send(.stopCapture)
        }
    }

    private var cameraController: some View {
        HStack {
            cameraList

            Menu("カメラデバイス位置") {
                Button("前面") {
                    selectedDevicePosition = .front
                }
                Button("背面") {
                    selectedDevicePosition = .back
                }
                Button("全て") {
                    selectedDevicePosition = .unspecified
                }
            }

            playButton
        }
    }

    private var cameraList: some View {
        Menu("カメラ一覧") {
            ForEach(devices) { device in
                Button(
                    action: {
                        selectedDevice = device
                    },
                    label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(selectedDevice == device ? .green : .gray)
                            Text("\(device.localizedName)")
                        }
                    }
                )
            }
        }
    }

    private let playIcon = Image(systemName: "play.circle.fill")
    private let pauseIcon = Image(systemName: "pause.circle.fill")

    private var playButton: some View {
        Button(
            action: {
                guard let selectedDevice else {
                    return
                }
                cameraCommands.send(isCameraCapturing ? .pauseCapture : .startCapture(device: selectedDevice))
                isCameraCapturing.toggle()
            },
            label: {
                isCameraCapturing ? pauseIcon : playIcon
            }
        )
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 600)
}

