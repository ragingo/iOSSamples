//
//  BlinkTracker.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/21.
//

import ARKit
import SceneKit

protocol BlinkTrackerDelegate {
    func didUpdate(result: BlinkTrackerResult)
}

struct BlinkTrackerResult {
    let isDrowsy: Bool

    let eyeBlinkLeft: CGFloat
    let eyeBlinkRight: CGFloat
}

final class BlinkTracker: NSObject {
    var delegate: BlinkTrackerDelegate?

    private var eyeClosedStartTime = Date()
    private var isEyeClosed = false

    func update(anchor: ARFaceAnchor) {
        let eyeBlinkLeft = CGFloat(anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? .zero)
        let eyeBlinkRight = CGFloat(anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? .zero)

        // 3秒継続したら「眠たそう」と判定する
        let isCurrentEyeClosed = eyeBlinkLeft > 0.4 || eyeBlinkRight > 0.4
        let isDrowsy: Bool
        if isCurrentEyeClosed {
            if isEyeClosed {
                let now = Date()
                let diff = now.timeIntervalSinceNow - eyeClosedStartTime.timeIntervalSinceNow
                isDrowsy = diff >= 3.0
            } else {
                isEyeClosed = true
                eyeClosedStartTime = Date()
                isDrowsy = false
            }
        } else {
            isEyeClosed = false
            isDrowsy = false
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let result = BlinkTrackerResult(isDrowsy: isDrowsy,
                                            eyeBlinkLeft: eyeBlinkLeft,
                                            eyeBlinkRight: eyeBlinkRight)
            self.delegate?.didUpdate(result: result)
        }
    }
}

extension BlinkTracker: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(anchor: faceAnchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(anchor: faceAnchor)
    }
}
