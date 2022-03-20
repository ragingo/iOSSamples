//
//  ContentView.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/20.
//

import ARKit
import SwiftUI

struct ContentView: View {
    @State private var distanceLabelText: String = ""
    @State private var leftEyePosition: SCNVector3 = SCNVector3Zero
    @State private var rightEyePosition: SCNVector3 = SCNVector3Zero
    @State private var lookAtX: Int = 0
    @State private var lookAtY: Int = 0

    var body: some View {
        if ARFaceTrackingConfiguration.isSupported {
            ZStack {
                ARViewController(distanceLabelText: $distanceLabelText,
                                 leftEyePosition: $leftEyePosition,
                                 rightEyePosition: $rightEyePosition,
                                 lookAtX: $lookAtX,
                                 lookAtY: $lookAtY)
                    .edgesIgnoringSafeArea(.all)

                if abs(lookAtX) > 500 {
                    Rectangle()
                        .stroke(.red, lineWidth: 10)
                        .edgesIgnoringSafeArea(.all)
                }

                VStack {
                    Text(distanceLabelText)
                    Text("left eye: x=\(leftEyePosition.x), y=\(leftEyePosition.y), z=\(leftEyePosition.z)")
                    Text("right eye: x=\(rightEyePosition.x), y=\(rightEyePosition.y), z=\(rightEyePosition.z)")
                    Text("look at: x=\(lookAtX), y=\(lookAtY)")
                }
            }
        } else {
            Text("顔認識非対応(T_T)")
                .padding()
        }
    }
}
