//
//  ContentView.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/11/30.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var camera: Camera?
    @State private var devices: [AVCaptureDevice] = []
    @State private var selectedDevice: AVCaptureDevice?
    @State private var selectedDevicePosition: AVCaptureDevice.Position = .unspecified
    @State private var showNotGrantedAlert = false

    init() {
    }

    var body: some View {
        VStack {
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
                    Task {
                        if await Camera.isAuthorized(for: .video) {
                            await camera?.startCapture()
                        } else {
                            showNotGrantedAlert = true
                        }
                    }
                }
                Button("Pause") {
                    Task {
                        await camera?.pauseCapture()
                    }
                }
                Button("Stop") {
                    Task {
                        await camera?.stopCapture()
                    }
                }
            }

            List(devices, id: \.uniqueID) { device in
                Button(device.description) {
                    selectedDevice = device
                }
                .foregroundStyle(Color.black)
                .background(selectedDevice == device ? Color.blue : Color.gray)
            }

            VideoSurfaceView(playerLayer: camera?.previewLayer)
                .frame(width: 300, height: 300)
                .clipped()
                .border(.red)
                .id(camera == nil ? 1 : 2)
        }
        .task {
            camera = await Camera()
        }
        .onAppear {
            devices = Camera.detectDevices()
            selectedDevice = devices.first
        }
        .onChange(of: selectedDevice) { _ in
            guard let selectedDevice else {
                return
            }
            Task {
                guard let camera else {
                    return
                }
                guard await camera.initializeCamera(device: selectedDevice) else {
                    return
                }
                await camera.startCapture()
            }
        }
        .onChange(of: selectedDevicePosition) { _ in
            devices = Camera.detectDevices(position: selectedDevicePosition)
        }
        .alert("カメラが許可されていません", isPresented: $showNotGrantedAlert) {
            Button("OSの設定画面を開く") {
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
        }
    }
}

#Preview {
    ContentView()
}

