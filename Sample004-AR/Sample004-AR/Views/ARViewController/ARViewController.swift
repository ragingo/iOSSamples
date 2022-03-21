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

    @Binding var isLookingAway: Bool
    @Binding var isDrowsy: Bool

    // MARK: - Debug Properties
    @Binding var distanceLabelText: String
    @Binding var eyePositionLeft: SCNVector3
    @Binding var eyePositionRight: SCNVector3
    @Binding var lookAtX: Int
    @Binding var lookAtY: Int
    @Binding var eyeBlinkLeft: CGFloat
    @Binding var eyeBlinkRight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.lookingDirectionTracker.delegate = context.coordinator
        viewController.blinkTracker.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ viewController: ViewController, context: Context) {
    }

    class Coordinator: NSObject {
        let parent: ARViewController

        init(_ viewController: ARViewController) {
            parent = viewController
        }
    }
}

extension ARViewController.Coordinator: LookingDirectionTrackerDelegate {
    func didUpdate(result: LookingDirectionTrackerResult) {
        parent.isLookingAway = result.isLookingAway
        parent.eyePositionLeft = result.eyePositionLeft
        parent.eyePositionRight = result.eyePositionRight

        // カメラとの距離
        let left = result.eyePositionLeft
        let right = result.eyePositionRight
        let distance = (left.length() + right.length()) / 2
        parent.distanceLabelText = "\(Int(round(distance * 100))) cm"

        // 視線
        // actual point size of iPhoneX screen
        let phoneScreenPointSize = CGSize(width: 375, height: 812)
        parent.lookAtX = Int(round(result.lookAtPositionX + phoneScreenPointSize.width / 2))
        parent.lookAtY = Int(round(result.lookAtPositionY + phoneScreenPointSize.height / 2))
    }
}

extension ARViewController.Coordinator: BlinkTrackerDelegate {
    func didUpdate(result: BlinkTrackerResult) {
        parent.isDrowsy = result.isDrowsy
        parent.eyeBlinkLeft = result.eyeBlinkLeft
        parent.eyeBlinkRight = result.eyeBlinkRight
    }
}

extension ARViewController {
    // 参考資料: https://dev.classmethod.jp/articles/eye-scrollable-web-view/
    class ViewController: UIViewController {
        let lookingDirectionTracker = LookingDirectionTracker()
        let blinkTracker = BlinkTracker()
        private let sceneView = ARSCNView()

        override func viewDidLoad() {
            super.viewDidLoad()

            sceneView.delegate = self
            sceneView.translatesAutoresizingMaskIntoConstraints = false
            sceneView.automaticallyUpdatesLighting = true
            view.addSubview(sceneView)

            lookingDirectionTracker.sceneView(sceneView: sceneView)

            NSLayoutConstraint.activate([
                sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                sceneView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true

            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            sceneView.session.pause()
        }
    }
}

extension ARViewController.ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        lookingDirectionTracker.renderer(renderer, updateAtTime: time)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        lookingDirectionTracker.renderer(renderer, didUpdate: node, for: anchor)
        blinkTracker.renderer(renderer, didUpdate: node, for: anchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        lookingDirectionTracker.renderer(renderer, didAdd: node, for: anchor)
        blinkTracker.renderer(renderer, didAdd: node, for: anchor)
    }
}
