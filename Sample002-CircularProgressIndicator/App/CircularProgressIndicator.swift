//
//  CircularProgressIndicator.swift
//  App
//
//  Created by ragingo on 2021/06/17.
//

import UIKit

@IBDesignable class CircularProgressIndicator: UIControl {
    private static let defaultBaseColor = UIColor.gray
    private static let defaultBarColor = UIColor.green
    private static let defaultBarWidth = CGFloat(2.0)

    private var baseLayer: CAShapeLayer
    private var barLayer: CAShapeLayer

    @IBInspectable var baseColor: UIColor = defaultBaseColor
    @IBInspectable var barColor: UIColor = defaultBarColor
    @IBInspectable var barWidth: CGFloat = defaultBarWidth

    var content: UIView?
    var contentSize: CGSize?
    var isContentAutoResize: Bool = false

    override init(frame: CGRect) {
        baseLayer = Self.makeBaseLayer()
        barLayer = Self.makeBarLayer()
        super.init(frame: frame)

        layer.addSublayer(baseLayer)
        layer.addSublayer(barLayer)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        baseLayer = Self.makeBaseLayer()
        barLayer = Self.makeBarLayer()
        super.init(coder: coder)

        layer.addSublayer(baseLayer)
        layer.addSublayer(barLayer)
        backgroundColor = .clear
    }

    private static func makeBaseLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = defaultBaseColor.cgColor
        layer.lineCap = .round
        layer.lineWidth = defaultBarWidth
        return layer
    }

    private static func makeBarLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = defaultBarColor.cgColor
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        layer.lineWidth = defaultBarWidth
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
        baseLayer.lineWidth = barWidth

        barLayer.strokeColor = barColor.cgColor
        barLayer.path = circle.cgPath
        barLayer.lineWidth = barWidth

        if let content = content, content.superview == nil {
            self.addSubview(content)
            self.bringSubviewToFront(content)
            content.translatesAutoresizingMaskIntoConstraints = false

            // 自動リサイズ
            if isContentAutoResize {
                let ratio = CGFloat(1.732 / 2.0) // √3 / 2 の比率を矩形の幅に掛けて、矩形を円の内側に収める
                self.addConstraints([
                    NSLayoutConstraint(
                        item: content, attribute: .width, relatedBy: .equal,
                        toItem: self, attribute: .width, multiplier: ratio, constant: 0
                    ),
                    NSLayoutConstraint(
                        item: content, attribute: .height, relatedBy: .equal,
                        toItem: self, attribute: .height, multiplier: ratio, constant: 0
                    )
                ])
            } else if let contentSize = contentSize {
                content.bounds = .init(origin: .zero, size: contentSize)
                content.addConstraints([
                    NSLayoutConstraint(
                        item: content, attribute: .width, relatedBy: .equal,
                        toItem: nil, attribute: .width, multiplier: 1.0, constant: contentSize.width
                    ),
                    NSLayoutConstraint(
                        item: content, attribute: .height, relatedBy: .equal,
                        toItem: nil, attribute: .height, multiplier: 1.0, constant: contentSize.height
                    )
                ])
            }

            // 上下中央揃え
            self.addConstraints([
                NSLayoutConstraint(
                    item: content, attribute: .centerX, relatedBy: .equal,
                    toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0
                ),
                NSLayoutConstraint(
                    item: content, attribute: .centerY, relatedBy: .equal,
                    toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0
                )
            ])
        }
    }

    func updateProgress(value: Double) {
        let strokeEnd = min(max(value, 0.0), 1.00)
        barLayer.strokeEnd = CGFloat(strokeEnd)
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
