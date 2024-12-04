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
    private let playerLayer: CALayer?

    init(playerLayer: CALayer?, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)
        if let playerLayer {
            layer.addSublayer(playerLayer)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
#elseif os(macOS)
final class VideoSurfaceUIView: NSView {
    private let playerLayer: CALayer?

    init(playerLayer: CALayer?) {
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
        playerLayer?.frame = self.bounds
    }
}
#endif

struct VideoSurfaceView: ViewRepresentable {
    var playerLayer: CALayer?

#if os(iOS)
    func makeUIView(context: Context) -> UIView {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

#elseif os(macOS)
    typealias NSViewType = NSView

    func makeNSView(context: Context) -> NSView {
        VideoSurfaceUIView(playerLayer: playerLayer)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
#endif
}
