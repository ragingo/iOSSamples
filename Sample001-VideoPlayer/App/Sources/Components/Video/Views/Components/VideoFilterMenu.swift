//
//  VideoFilterMenu.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import SwiftUI

struct VideoFilterMenu: View {
    let action: (VideoFilter) -> Void

    @State private var selectedFilter: VideoFilter?

    var body: some View {
        Menu(
            content: {
                ForEach(VideoFilter.allCases) { filter in
                    Button(
                        action: {
                            action(filter)
                            selectedFilter = filter
                        },
                        label: {
                            Text("\(selectedFilter == filter ? "✅️" : "☑️") \(filter.rawValue)")
                        }
                    )
                }
            },
            label: {
                Image(systemName: "lightspectrum.horizontal")
            }
        )
    }
}

extension VideoFilterMenu: Equatable {
    static func == (lhs: VideoFilterMenu, rhs: VideoFilterMenu) -> Bool {
        lhs.selectedFilter == rhs.selectedFilter
    }
}

#Preview {
    VideoFilterMenu(action: { _ in })
}
