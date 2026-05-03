//
//  VideoRateMenu.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import SwiftUI

struct VideoRateMenu: View {
    let action: (VideoRate) -> Void

    @State private var selectedRate: VideoRate?

    var body: some View {
        Menu(
            content: {
                ForEach(VideoRate.allCases) { rate in
                    Button(
                        action: {
                            action(rate)
                            selectedRate = rate
                        },
                        label: {
                            Text("\(selectedRate == rate ? "✅️" : "☑️") \(rate.rawValue)")
                        }
                    )
                }
            },
            label: {
                Image(systemName: "gauge.open.with.lines.needle.33percent")
            }
        )
    }
}

extension VideoRateMenu: Equatable {
    static func == (lhs: VideoRateMenu, rhs: VideoRateMenu) -> Bool {
        lhs.selectedRate == rhs.selectedRate
    }
}

#Preview {
    VideoRateMenu(action: { _ in })
}
