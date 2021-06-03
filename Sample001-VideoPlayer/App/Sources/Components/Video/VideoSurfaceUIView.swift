//
//  VideoSurfaceUIView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import AVFoundation
import UIKit

// AVPlayerLayer をラップした UIView 派生クラス
// SwiftUI と繋ぐために作った
final class VideoSurfaceUIView: UIView {
    private let playerLayer: AVPlayerLayer = AVPlayerLayer()
    private let player: AVPlayer

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(player: AVPlayer, frame: CGRect) {
        self.player = player
        super.init(frame: frame)

        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
