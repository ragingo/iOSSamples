//
//  ContentView.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/11/30.
//

import SwiftUI

struct ContentView: View {
    @State private var camera: Camera = .init()

    init() {
    }

    private func initializeCamera() {
        guard camera.initializeCamera() else {
            return
        }
    }

    var body: some View {
        VideoSurfaceView(playerLayer: camera.previewLayer)
            .onAppear {
                initializeCamera()
                Task {
                    await camera.startPreview()
                }
            }
    }
}

#Preview {
    ContentView()
}

