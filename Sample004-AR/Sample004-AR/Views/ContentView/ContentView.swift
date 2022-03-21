//
//  ContentView.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import ARKit
import SwiftUI

struct ContentView: View {
    @State private var feedbackGenerator: UINotificationFeedbackGenerator?
    @State private var isLookingAway: Bool = false
    @State private var isDrowsy: Bool = false

    // MARK: - Debug Properties
    @State private var eyePositionLeft: SCNVector3 = SCNVector3Zero
    @State private var eyePositionRight: SCNVector3 = SCNVector3Zero
    @State private var eyeBlinkLeft: CGFloat = .zero
    @State private var eyeBlinkRight: CGFloat = .zero
    @State private var lookAtX: Int = 0
    @State private var lookAtY: Int = 0

    init() {
        feedbackGenerator = UINotificationFeedbackGenerator()
    }

    var body: some View {
        if ARFaceTrackingConfiguration.isSupported {
            supportedView
        } else {
            unsupportedView
        }
    }
}

private extension ContentView {
    var supportedView: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)

            if isLookingAway || isDrowsy {
                Rectangle()
                    .stroke(.red, lineWidth: 10)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        self.feedbackGenerator?.notificationOccurred(.error)
                    }
            }

            debugView
        }
        .onAppear {
            self.feedbackGenerator = UINotificationFeedbackGenerator()
            self.feedbackGenerator?.prepare()
        }
    }

    var arView: some View {
        ARViewController(isLookingAway: $isLookingAway,
                         isDrowsy: $isDrowsy,
                         eyePositionLeft: $eyePositionLeft,
                         eyePositionRight: $eyePositionRight,
                         lookAtX: $lookAtX,
                         lookAtY: $lookAtY,
                         eyeBlinkLeft: $eyeBlinkLeft,
                         eyeBlinkRight: $eyeBlinkRight)
    }

    var debugView: some View {
        VStack {
            Text("eye pos l: x=\(eyePositionLeft.x), y=\(eyePositionLeft.y), z=\(eyePositionLeft.z)")
            Text("eye pos r: x=\(eyePositionRight.x), y=\(eyePositionRight.y), z=\(eyePositionRight.z)")
            Text("eye blink l: \(eyeBlinkLeft)")
            Text("eye blink r: \(eyeBlinkRight)")
            Text("look at: x=\(lookAtX), y=\(lookAtY)")
        }
    }

    var unsupportedView: some View {
        Text("顔認識非対応(T_T)")
    }
}
