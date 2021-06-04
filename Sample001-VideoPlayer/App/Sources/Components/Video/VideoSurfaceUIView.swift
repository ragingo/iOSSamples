//
//  VideoSurfaceUIView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import UIKit

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
