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
    @Binding var eyeBlinkLeft: CGFloat
    @Binding var eyeBlinkRight: CGFloat
    @Binding var lookAtX: Int
    @Binding var lookAtY: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.eyeTracker.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ viewController: ViewController, context: Context) {
    }

    class Coordinator: NSObject, EyeTrackerDelegate {
        let parent: ARViewController
        init(_ viewController: ARViewController) {
            parent = viewController
        }

        func didUpdate(result: EyeTrackerResult) {
            parent.isLookingAway = result.isLookingAway
            parent.isDrowsy = result.isDrowsy

            parent.eyePositionLeft = result.eyePositionLeft
            parent.eyePositionRight = result.eyePositionRight
            parent.eyeBlinkLeft = result.eyeBlinkLeft
            parent.eyeBlinkRight = result.eyeBlinkRight

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
}

extension ARViewController {
    // 参考資料: https://dev.classmethod.jp/articles/eye-scrollable-web-view/
    class ViewController: UIViewController {
        let eyeTracker = EyeTracker()

        override func viewDidLoad() {
            super.viewDidLoad()

            eyeTracker.sceneView.automaticallyUpdatesLighting = true
            view.addSubview(eyeTracker.sceneView)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true

            eyeTracker.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            eyeTracker.sceneView.session.pause()
        }
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

