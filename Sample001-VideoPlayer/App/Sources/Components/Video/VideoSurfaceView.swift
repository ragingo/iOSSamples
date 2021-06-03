//
//  VideoSurfaceView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import AVFoundation
import SwiftUI

// 映像部分の View
struct VideoSurfaceView: UIViewRepresentable {
    private let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    func makeUIView(context: Context) -> UIView {
        VideoSurfaceUIView(player: player, frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
