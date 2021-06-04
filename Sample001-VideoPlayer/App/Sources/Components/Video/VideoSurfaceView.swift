//
//  VideoSurfaceView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

// 映像部分の View
struct VideoSurfaceView: UIViewRepresentable {
    let playerLayer: CALayer

    func makeUIView(context: Context) -> UIView {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
