//
//  ARViewController.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import SwiftUI
import SceneKit
import ARKit

struct ARViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    @Binding var distanceLabelText: String
    @Binding var leftEyePosition: SCNVector3
    @Binding var rightEyePosition: SCNVector3
    @Binding var lookAtX: Int
    @Binding var lookAtY: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ viewController: ViewController, context: Context) {
    }

    class Coordinator: NSObject, ViewControllerDelegate {
        let parent: ARViewController
        init(_ viewController: ARViewController) {
            parent = viewController
        }

        func onUpdated(leftEyePosition: SCNVector3,
                       rightEyePosition: SCNVector3,
                       lookAtPositionX: CGFloat,
                       lookAtPositionY: CGFloat) {
            // カメラとの距離
            let left = leftEyePosition
            let right = rightEyePosition
            let distance = (left.length() + right.length()) / 2
            parent.distanceLabelText = "\(Int(round(distance * 100))) cm"

            parent.leftEyePosition = leftEyePosition
            parent.rightEyePosition = rightEyePosition

            // 視線
            // actual point size of iPhoneX screen
            let phoneScreenPointSize = CGSize(width: 375, height: 812)
            parent.lookAtX = Int(round(lookAtPositionX + phoneScreenPointSize.width / 2))
            parent.lookAtY = Int(round(lookAtPositionY + phoneScreenPointSize.height / 2))
        }
    }
}

protocol ViewControllerDelegate {
    func onUpdated(leftEyePosition: SCNVector3,
                   rightEyePosition: SCNVector3,
                   lookAtPositionX: CGFloat,
                   lookAtPositionY: CGFloat)
}

extension ARViewController {
    // 参考資料: https://dev.classmethod.jp/articles/eye-scrollable-web-view/
    class ViewController: UIViewController {
        var delegate: ViewControllerDelegate?
        var lookAtTargetEyeLNode: SCNNode = SCNNode()
        var lookAtTargetEyeRNode: SCNNode = SCNNode()
        // actual physical size of iPhoneX screen
        let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
        // actual point size of iPhoneX screen
        let phoneScreenPointSize = CGSize(width: 375, height: 812)
        var virtualPhoneNode: SCNNode = SCNNode()
        var virtualScreenNode: SCNNode = {
            let screenGeometry = SCNPlane(width: 1, height: 1)
            screenGeometry.firstMaterial?.isDoubleSided = true
            screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
            return SCNNode(geometry: screenGeometry)
        }()
        var eyeLookAtPositionXs: [CGFloat] = []
        var eyeLookAtPositionYs: [CGFloat] = []
        var faceNode: SCNNode = SCNNode()

        var eyeLNode: SCNNode = {
            let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
            geometry.radialSegmentCount = 3
            geometry.firstMaterial?.diffuse.contents = UIColor.blue
            let node = SCNNode()
            node.geometry = geometry
            node.eulerAngles.x = -.pi / 2
            node.position.z = 0.1
            let parentNode = SCNNode()
            parentNode.addChildNode(node)
            return parentNode
        }()

        var eyeRNode: SCNNode = {
            let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
            geometry.radialSegmentCount = 3
            geometry.firstMaterial?.diffuse.contents = UIColor.blue
            let node = SCNNode()
            node.geometry = geometry
            node.eulerAngles.x = -.pi / 2
            node.position.z = 0.1
            let parentNode = SCNNode()
            parentNode.addChildNode(node)
            return parentNode
        }()

        override var preferredStatusBarStyle: UIStatusBarStyle {
            return UIStatusBarStyle.lightContent
        }

        var sceneView: ARSCNView!
    //    var eyePositionIndicatorView: UIView!
    //    var eyePositionIndicatorCenterView: UIView!
    //    var lookAtPositionXLabel: UILabel!
    //    var lookAtPositionYLabel: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()

            sceneView = .init(frame: .init(origin: .init(x: 0, y: 0), size: .init(width: 500, height: 1000)))
            self.view.addSubview(sceneView)

            // Setup Design Elements
            //eyePositionIndicatorView.layer.cornerRadius = eyePositionIndicatorView.bounds.width / 2
            sceneView.layer.cornerRadius = 28
            //eyePositionIndicatorCenterView.layer.cornerRadius = 4

            sceneView.delegate = self
            sceneView.session.delegate = self
            sceneView.automaticallyUpdatesLighting = true

            // Setup Scenegraph
            sceneView.scene.rootNode.addChildNode(faceNode)
            sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
            virtualPhoneNode.addChildNode(virtualScreenNode)
            faceNode.addChildNode(eyeLNode)
            faceNode.addChildNode(eyeRNode)
            eyeLNode.addChildNode(lookAtTargetEyeLNode)
            eyeRNode.addChildNode(lookAtTargetEyeRNode)

            // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
            lookAtTargetEyeLNode.position.z = 2
            lookAtTargetEyeRNode.position.z = 2
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Create a session configuration
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true

            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            sceneView.session.pause()
        }

        // MARK: - update(ARFaceAnchor)

        func update(withFaceAnchor anchor: ARFaceAnchor) {
            eyeRNode.simdTransform = anchor.rightEyeTransform
            eyeLNode.simdTransform = anchor.leftEyeTransform

            var eyeLLookAt = CGPoint()
            var eyeRLookAt = CGPoint()

            let heightCompensation: CGFloat = 312

            DispatchQueue.main.async {
                let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)

                let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)

                for result in phoneScreenEyeRHitTestResults {
                    eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }

                for result in phoneScreenEyeLHitTestResults {
                    eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }

                // Add the latest position and keep up to 8 recent position to smooth with.
                let smoothThresholdNumber: Int = 10
                self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
                self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
                self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
                self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))

                // update indicator position
                //self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)

                self.delegate?.onUpdated(leftEyePosition: self.eyeLNode.worldPosition,
                                         rightEyePosition: self.eyeRNode.worldPosition,
                                         lookAtPositionX: self.eyeLookAtPositionXs.average!,
                                         lookAtPositionY: self.eyeLookAtPositionYs.average!)
            }
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            faceNode.transform = node.transform
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            update(withFaceAnchor: faceAnchor)
        }
    }
}

extension ARViewController.ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }
}

extension ARViewController.ViewController: ARSessionDelegate {}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

extension Collection where Element == CGFloat, Index == Int {
    /// Return the mean of a list of CGFloat. Used with `recentVirtualObjectDistances`.
    var average: CGFloat? {
        guard !isEmpty else {
            return nil
        }

        let sum = reduce(CGFloat(0)) { current, next -> CGFloat in
            return current + next
        }

        return sum / CGFloat(count)
    }
}

