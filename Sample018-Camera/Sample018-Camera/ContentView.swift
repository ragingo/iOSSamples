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

    private let cameraCommands = PassthroughSubject<CameraPreview.Command, Never>()

    var body: some View {
        VStack {
            cameraController

            List(devices, id: \.uniqueID) { device in
                Button(device.description) {
                    selectedDevice = device
                }
                .foregroundStyle(Color.black)
                .background(selectedDevice == device ? Color.blue : Color.gray)
            }

            CameraPreview(commands: cameraCommands.receive(on: RunLoop.main).eraseToAnyPublisher())
                //.notGrantedAlert(isPresent: $showNotGrantedAlert)
                .onDeviceListLoaded { devices in
                    self.devices = devices.map { $0 }
                }
                .frame(width: 300, height: 300)
                .clipped()
                .border(.red)
        }
        .onAppear {
            cameraCommands.send(.loadDevices(position: selectedDevicePosition))
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
}

