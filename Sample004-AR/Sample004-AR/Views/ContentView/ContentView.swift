//
//  ContentView.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import ARKit
import SwiftUI

struct ContentView: View {
    @State private var isLookingAway: Bool = false
    @State private var isDrowsy: Bool = false

    // MARK: - Debug Properties
    @State private var distanceLabelText: String = ""
    @State private var eyePositionLeft: SCNVector3 = SCNVector3Zero
    @State private var eyePositionRight: SCNVector3 = SCNVector3Zero
    @State private var eyeBlinkLeft: CGFloat = .zero
    @State private var eyeBlinkRight: CGFloat = .zero
    @State private var lookAtX: Int = 0
    @State private var lookAtY: Int = 0

    var body: some View {
        if ARFaceTrackingConfiguration.isSupported {
            ZStack {
                ARViewController(isLookingAway: $isLookingAway,
                                 isDrowsy: $isDrowsy,
                                 distanceLabelText: $distanceLabelText,
                                 eyePositionLeft: $eyePositionLeft,
                                 eyePositionRight: $eyePositionRight,
                                 lookAtX: $lookAtX,
                                 lookAtY: $lookAtY,
                                 eyeBlinkLeft: $eyeBlinkLeft,
                                 eyeBlinkRight: $eyeBlinkRight)
                    .edgesIgnoringSafeArea(.all)

                if isLookingAway || isDrowsy {
                    Rectangle()
                        .stroke(.red, lineWidth: 10)
                        .edgesIgnoringSafeArea(.all)
                }

                VStack {
                    Text(distanceLabelText)
                    Text("eye pos l: x=\(eyePositionLeft.x), y=\(eyePositionLeft.y), z=\(eyePositionLeft.z)")
                    Text("eye pos r: x=\(eyePositionRight.x), y=\(eyePositionRight.y), z=\(eyePositionRight.z)")
                    Text("eye blink l: \(eyeBlinkLeft)")
                    Text("eye blink r: \(eyeBlinkRight)")
                    Text("look at: x=\(lookAtX), y=\(lookAtY)")
                }
            }
        } else {
            Text("顔認識非対応(T_T)")
                .padding()
        }
    }
}
