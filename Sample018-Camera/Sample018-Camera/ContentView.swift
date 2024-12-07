//
//  ContentView.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/11/30.
//

import AVFoundation
import Combine
import SwiftUI

struct ContentView: View {
    @State private var devices: [AVCaptureDevice] = []
    @State private var selectedDevice: AVCaptureDevice?
    @State private var selectedDevicePosition: AVCaptureDevice.Position = .unspecified

    private let cameraCommands = CurrentValueSubject<CameraPreview.Command, Never>(.empty)

    var body: some View {
        VStack {
            cameraController
                .padding()

            List(devices, id: \.uniqueID) { device in
                Button(device.description) {
                    selectedDevice = device
                }
                .foregroundStyle(Color.black)
                .background(selectedDevice == device ? Color.blue : Color.gray)
            }

            CameraPreview(commands: cameraCommands.eraseToAnyPublisher())
                .onInitialized {
                    cameraCommands.send(.loadDevices(position: selectedDevicePosition))
                }
                .onDeviceListLoaded { devices in
                    self.devices = devices
                }
                .frame(width: 300, height: 300)
                .clipped()
                .border(.red)
        }
        .onChange(of: selectedDevice) { _ in
            guard let selectedDevice else {
                return
            }
            cameraCommands.send(.selectDevice(device: selectedDevice))
        }
        .onChange(of: selectedDevicePosition) { _ in
            cameraCommands.send(.loadDevices(position: selectedDevicePosition))
        }
    }

    private var cameraController: some View {
        HStack {
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
            Button("Start") {
                cameraCommands.send(.startCapture)
            }
            Button("Pause") {
                cameraCommands.send(.pauseCapture)
            }
            Button("Stop") {
                cameraCommands.send(.stopCapture)
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 600)
}

