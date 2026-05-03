//
//  VideoQualityMenu.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import SwiftUI

struct VideoQualityMenu: View {
    @Binding var qualities: [Int]
    let action: (Int) -> Void

    @State private var selectedValue: Int?

    var body: some View {
        Menu(
            content: {
                ForEach($qualities.wrappedValue, id: \.self) { value in
                    Button(
                        action: {
                            action(value)
                            selectedValue = value
                        },
                        label: {
                            Text("\(selectedValue == value ? "✅️" : "☑️") \(value)")
                        }
                    )
                }
            },
            label: {
                Image(systemName: "list.number")
            }
        )
    }
}

extension VideoQualityMenu: Equatable {
    static func == (lhs: VideoQualityMenu, rhs: VideoQualityMenu) -> Bool {
        lhs.qualities == rhs.qualities
        && lhs.selectedValue == rhs.selectedValue
    }
}

#Preview {
    @Previewable @State var qualities = [1, 10, 100, 1_000, 10_000, 100_000]
    VideoQualityMenu(qualities: $qualities, action: { _ in })
}
