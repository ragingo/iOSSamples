//
//  Widget.swift
//  Widget
//
//  Created by ragingo on 2022/09/18.
//

import WidgetKit
import SwiftUI
import ActivityKit

@main
struct Widgets: WidgetBundle {
    var body: some Widget {
        SampleWidget()
    }
}

struct SampleWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SimpleAttributes.self) { context in
            EmptyView()
        } dynamicIsland: { context in
            DynamicIsland(
                expanded: {
                    DynamicIslandExpandedRegion(.leading) {
                        leftEye
                            .rotationEffect(.degrees(context.state.angle))
                            .animation(.easeInOut, value: context.state.angle)
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        rightEye
                            .rotationEffect(.degrees(context.state.angle))
                            .animation(.easeInOut, value: context.state.angle)
                    }
                    DynamicIslandExpandedRegion(.center) {
                        nose
                            .rotationEffect(.degrees(context.state.angle))
                            .animation(.easeInOut, value: context.state.angle)
                    }
                    DynamicIslandExpandedRegion(.bottom) {
                        mouth
                            .rotationEffect(.degrees(context.state.angle))
                            .animation(.easeInOut, value: context.state.angle)
                    }
                },
                compactLeading: {
                    Image(systemName: "arrow.right.circle")
                },
                compactTrailing: {
                    Image(systemName: "arrow.left.circle")
                },
                minimal: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            )
        }
        .configurationDisplayName("Sample008-DynamicIsland-Widget")
        .description("DynamicIsland test app")
    }

    private var leftEye: some View {
        Image(systemName: "eye")
            .foregroundColor(.orange)
    }

    private var rightEye: some View {
        Image(systemName: "eye")
            .foregroundColor(.green)
    }

    private var nose: some View {
        Image(systemName: "nose")
            .foregroundColor(.blue)
    }

    private var mouth: some View {
        Image(systemName: "mouth")
            .foregroundColor(.red)
    }
}
