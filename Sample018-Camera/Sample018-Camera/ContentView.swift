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

#if os(macOS)
typealias UIViewRepresentable = NSViewRepresentable
typealias UIView = NSView
typealias UIViewControllerRepresentable = NSViewControllerRepresentable
#endif

final class VideoSurfaceUIView: UIView {
    private let playerLayer: CALayer

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(playerLayer: CALayer, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)

        #if os(iOS)
        layer.addSublayer(playerLayer)
        #elseif os(macOS)
        layer?.addSublayer(playerLayer)
        #endif
    }

    #if os(iOS)
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    #endif
}

struct VideoSurfaceView: UIViewRepresentable {
    #if os(macOS)
    typealias NSViewType = UIView
    func makeNSView(context: Context) -> UIView {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateNSView(_ uiView: UIView, context: Context) {
    }
    #endif

    var playerLayer: CALayer

    func makeUIView(context: Context) -> UIView {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}


#Preview {
    ContentView()
}

