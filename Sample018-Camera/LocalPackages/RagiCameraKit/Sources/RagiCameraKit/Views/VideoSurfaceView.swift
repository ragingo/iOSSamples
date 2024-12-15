//
//  VideoSurfaceView.swift
//  Sample018-Camera
//
//  Created by ragingo on 2024/12/03.
//

import SwiftUI

#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias ViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif

#if os(iOS)
final class VideoSurfaceUIView: UIView {
    private let playerLayer: CALayer

    init(playerLayer: CALayer, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
#elseif os(macOS)
final class VideoSurfaceUIView: NSView {
    private let playerLayer: CALayer

    init(playerLayer: CALayer) {
        self.playerLayer = playerLayer
        super.init(frame: .zero)
        self.layer = playerLayer
        self.wantsLayer = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        playerLayer.frame = self.bounds
    }
}
#endif

struct VideoSurfaceView: ViewRepresentable {
    var playerLayer: CALayer

#if os(iOS)
    typealias UIViewType = VideoSurfaceUIView

    func makeUIView(context: Context) -> UIViewType {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }

#elseif os(macOS)
    typealias NSViewType = VideoSurfaceUIView

    func makeNSView(context: Context) -> NSViewType {
        VideoSurfaceUIView(playerLayer: playerLayer)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
#endif
}
