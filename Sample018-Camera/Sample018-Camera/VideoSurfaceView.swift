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

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(playerLayer: CALayer, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
#endif

struct VideoSurfaceView: ViewRepresentable {
    var playerLayer: CALayer

#if os(iOS)
    func makeUIView(context: Context) -> UIView {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

#elseif os(macOS)
    typealias NSViewType = NSView

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.layer = playerLayer
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
#endif
}
