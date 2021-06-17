//
//  CircularProgressIndicator.swift
//  App
//
//  Created by ragingo on 2021/06/17.
//

import UIKit

class CircularProgressIndicator: UIControl {
    private static let defaultBaseColor = UIColor.gray
    private static let defaultBarColor = UIColor.green

    private var baseLayer: CAShapeLayer
    private var barLayer: CAShapeLayer

    var baseColor: UIColor = .gray
    var barColor: UIColor = .green
    var content: UIView?

    override init(frame: CGRect) {
        baseLayer = Self.makeBaseLayer()
        barLayer = Self.makeBarLayer()
        super.init(frame: frame)

        layer.addSublayer(baseLayer)
        layer.addSublayer(barLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeBaseLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Self.defaultBaseColor.cgColor
        layer.lineCap = .round
        layer.lineWidth = 2.0
        return layer
    }

    private static func makeBarLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Self.defaultBarColor.cgColor
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        layer.lineWidth = 2.0
        return layer
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let radius = bounds.size.width / 2.0
        let startAngle = -CGFloat.pi / 2.0
        let endAngle = CGFloat.pi * (3.0 / 2.0)
        let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        baseLayer.strokeColor = baseColor.cgColor
        baseLayer.path = circle.cgPath

        barLayer.strokeColor = barColor.cgColor
        barLayer.path = circle.cgPath

        if let content = content {
            if !self.subviews.contains(where: { v in v == content }) {
                self.addSubview(content)
                self.bringSubviewToFront(content)
                content.translatesAutoresizingMaskIntoConstraints = false

                let ratio = 1.732 / 2.0 // √3 / 2 の比率を矩形の幅に掛けて、矩形を円の内側に収める
                self.addConstraints([
                    NSLayoutConstraint(
                        item: content, attribute: .centerX, relatedBy: .equal,
                        toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0
                    ),
                    NSLayoutConstraint(
                        item: content, attribute: .centerY, relatedBy: .equal,
                        toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0
                    ),
                    NSLayoutConstraint(
                        item: content, attribute: .width, relatedBy: .equal,
                        toItem: self, attribute: .width, multiplier: ratio, constant: 0
                    ),
                    NSLayoutConstraint(
                        item: content, attribute: .height, relatedBy: .equal,
                        toItem: self, attribute: .height, multiplier: ratio, constant: 0
                    )
                ])

            }
        }
    }

    func updateProgress(value: Double) {
        // TODO: validation
        barLayer.strokeEnd = value
    }

    // 主にデバッグ用
    func updateProgressWithAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.toValue = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true // 完了時に消えるからデバッグに便利
        barLayer.add(animation, forKey: "strokeEndAnimation")
    }
}
