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
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let radius = frame.size.width / 2.0
        let startAngle = CGFloat.pi / 2.0 * -1
        let endAngle = 3 * CGFloat.pi / 2.0
        let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        baseLayer.strokeColor = baseColor.cgColor
        baseLayer.path = circle.cgPath

        barLayer.strokeColor = barColor.cgColor
        barLayer.path = circle.cgPath
    }

    func updateProgress(value: Double) {
        // TODO: validation
        barLayer.strokeEnd = value
    }

    func updateProgressWithAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.toValue = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        barLayer.add(animation, forKey: "strokeEndAnimation")
    }
}
