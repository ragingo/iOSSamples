//
//  EyeTracker.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import ARKit
import SceneKit
import Collections

protocol EyeTrackerDelegate {
    func didUpdate(result: EyeTrackerResult)
}

struct EyeTrackerResult {
    let isLookingAway: Bool
    let isDrowsy: Bool

    let eyePositionLeft: SCNVector3
    let eyePositionRight: SCNVector3
    let eyeBlinkLeft: CGFloat
    let eyeBlinkRight: CGFloat
    let lookAtPositionX: CGFloat
    let lookAtPositionY: CGFloat
}

final class EyeTracker: NSObject {
    var delegate: EyeTrackerDelegate?
    let sceneView = ARSCNView(frame: .init(x: 0, y: 0, width: 1, height: 1))

    private let faceNode = SCNNode()
    private let eyeLeftNode = SCNNode()
    private let eyeRightNode = SCNNode()
    private let targetEyeLeftNode = SCNNode()
    private let targetEyeRightNode = SCNNode()
    private var eyeLookAtPositionXs = Deque<CGFloat>()
    private var eyeLookAtPositionYs = Deque<CGFloat>()
    private let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    private let phoneScreenPointSize = CGSize(width: 375, height: 812)
    private let virtualPhoneNode = SCNNode()
    private let virtualScreenNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))

    private var eyeClosedStartTime = Date()
    private var isEyeClosed = false

    // 余所見しているかどうか
    // だいぶ雑
    private var isLookingAway: Bool {
        let x = Int(round(eyeLookAtPositionXs.average + phoneScreenPointSize.width / 2))
        return abs(x) > 500
    }

    override init() {
        super.init()
        sceneView.delegate = self
        sceneView.session.delegate = self

        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLeftNode)
        faceNode.addChildNode(eyeRightNode)
        eyeLeftNode.addChildNode(targetEyeLeftNode)
        eyeRightNode.addChildNode(targetEyeRightNode)

        // 視線の先のターゲットまでの距離を設定
        targetEyeLeftNode.position.z = 0.5
        targetEyeRightNode.position.z = 0.5
    }

    private func lookAt(from: SCNVector3, to: SCNVector3) -> CGPoint {
        let results = virtualPhoneNode.hitTestWithSegment(from: from, to: to)
        guard let result = results.last else {
            return .zero
        }
        let x = CGFloat(result.localCoordinates.x) / (phoneScreenSize.width / 2) * phoneScreenPointSize.width
        let y = CGFloat(result.localCoordinates.y) / (phoneScreenSize.height / 2) * phoneScreenPointSize.height
        return CGPoint(x: x, y: y)
    }

    func update(withFaceAnchor anchor: ARFaceAnchor) {
        eyeRightNode.simdTransform = anchor.rightEyeTransform
        eyeLeftNode.simdTransform = anchor.leftEyeTransform

        let eyeBlinkLeft = CGFloat(anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? .zero)
        let eyeBlinkRight = CGFloat(anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? .zero)
        // TODO: 5秒継続したら「眠たそう」と判定する
        let isCurrentEyeClosed = eyeBlinkLeft > 0.4 || eyeBlinkRight > 0.4
        let isDrowsy: Bool
        if isCurrentEyeClosed {
            if isEyeClosed {
                let now = Date()
                let diff = now.timeIntervalSinceNow - eyeClosedStartTime.timeIntervalSinceNow
                isDrowsy = diff > 3.0
            } else {
                isEyeClosed = true
                eyeClosedStartTime = Date()
                isDrowsy = false
            }
        } else {
            isEyeClosed = false
            isDrowsy = false
        }

        let lookAtLeft = lookAt(from: targetEyeLeftNode.worldPosition, to: eyeLeftNode.worldPosition)
        let lookAtRight = lookAt(from: targetEyeRightNode.worldPosition, to: eyeRightNode.worldPosition)

        // 最新の10件だけを保持する
        let capacity = 10
        if eyeLookAtPositionXs.count == capacity {
            _ = eyeLookAtPositionXs.popFirst()
        }
        if eyeLookAtPositionYs.count == capacity {
            _ = eyeLookAtPositionYs.popFirst()
        }
        eyeLookAtPositionXs.append((lookAtRight.x + lookAtLeft.x) / 2)
        eyeLookAtPositionYs.append(-(lookAtRight.y + lookAtLeft.y) / 2)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let result = EyeTrackerResult(isLookingAway: self.isLookingAway,
                                          isDrowsy: isDrowsy,
                                          eyePositionLeft: self.eyeLeftNode.worldPosition,
                                          eyePositionRight: self.eyeRightNode.worldPosition,
                                          eyeBlinkLeft: eyeBlinkLeft,
                                          eyeBlinkRight: eyeBlinkRight,
                                          lookAtPositionX: self.eyeLookAtPositionXs.average,
                                          lookAtPositionY: self.eyeLookAtPositionYs.average)
            self.delegate?.didUpdate(result: result)
        }
    }
}

extension EyeTracker: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }
}

extension EyeTracker: ARSessionDelegate {
}
