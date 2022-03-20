//
//  EyeTracker.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import ARKit
import SceneKit

protocol EyeTrackerDelegate {
    func didUpdate(leftEyePosition: SCNVector3,
                   rightEyePosition: SCNVector3,
                   lookAtPositionX: CGFloat,
                   lookAtPositionY: CGFloat)
}

final class EyeTracker: NSObject {
    var delegate: EyeTrackerDelegate?
    let faceNode = SCNNode()
    let eyeLeftNode = SCNNode()
    let eyeRightNode = SCNNode()
    let targetEyeLeftNode = SCNNode()
    let targetEyeRightNode = SCNNode()
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    let virtualPhoneNode = SCNNode()
    let virtualScreenNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    let sceneView = ARSCNView(frame: .init(x: 0, y: 0, width: 500, height: 500))

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

        let lookAtLeft = lookAt(from: targetEyeLeftNode.worldPosition, to: eyeLeftNode.worldPosition)
        let lookAtRight = lookAt(from: targetEyeRightNode.worldPosition, to: eyeRightNode.worldPosition)

        // 最新の10件だけを保持する
        let capacity = 10
        eyeLookAtPositionXs.append((lookAtRight.x + lookAtLeft.x) / 2)
        eyeLookAtPositionYs.append(-(lookAtRight.y + lookAtLeft.y) / 2)
        eyeLookAtPositionXs = Array(eyeLookAtPositionXs.suffix(capacity))
        eyeLookAtPositionYs = Array(eyeLookAtPositionYs.suffix(capacity))

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.didUpdate(leftEyePosition: self.eyeLeftNode.worldPosition,
                                     rightEyePosition: self.eyeRightNode.worldPosition,
                                     lookAtPositionX: self.eyeLookAtPositionXs.average,
                                     lookAtPositionY: self.eyeLookAtPositionYs.average)
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
