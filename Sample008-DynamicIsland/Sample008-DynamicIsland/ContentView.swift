//
//  ContentView.swift
//  Sample008-DynamicIsland
//
//  Created by ragingo on 2022/09/18.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var isDynamicEyelandEnabled = false
    @State private var activity: Activity<SimpleAttributes>?

    var body: some View {
        VStack {
            Toggle(isOn: $isDynamicEyelandEnabled) {
                Text("実行")
            }
        }
        .padding()
        .onChange(of: isDynamicEyelandEnabled) { isEnabled in
            if isEnabled {
                startActivity()
            } else {
                stopActivity()
            }
        }
        .onReceive(timer) { _ in
            Task {
                if let activity {
                    let angle = activity.contentState.angle + 10.0
                    let state = SimpleAttributes.State(angle: angle >= 360.0 ? 0.0 : angle)
                    await activity.update(using: state)
                }
            }
        }
    }

    private func startActivity() {
        print("areActivitiesEnabled: \(ActivityAuthorizationInfo().areActivitiesEnabled)")
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            return
        }

        do {
            let attributes = SimpleAttributes()
            let state = SimpleAttributes.State()
            activity = try Activity<SimpleAttributes>.request(attributes: attributes, contentState: state)
        } catch {
            print(error)
        }
    }

    private func stopActivity() {
        Task {
            for activity in Activity<SimpleAttributes>.activities {
                await activity.end(dismissalPolicy: .default)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
