//
//  VideoQualityMenu.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import SwiftUI

struct VideoQualityMenu: View {
    @Binding var qualities: [VideoQuality]
    let action: (VideoQuality) -> Void

    @State private var selectedValue: VideoQuality?

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
                            Text(
                                "\(selectedValue == value ? "✅️" : "☑️") \(value.label)"
                            )
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

private extension VideoQuality {
    var label: String {
        let bitRate = Int(peakBitRate ?? .zero)
        var bitRateString = ""

        switch bitRate {
        case 0 ..< 1_000:
            bitRateString = "\(bitRate) bps"
        case 1_000 ..< 1_000_000:
            bitRateString = "\(bitRate / 1_000) Kbps"
        case 1_000_000 ..< 1_000_000_000:
            bitRateString = "\(bitRate / 1_000_000) Mbps"
        default:
            bitRateString = ""
        }
        return "\(width)x\(height) (\(bitRateString))"
    }
}

#Preview("空") {
    @Previewable @State var qualities: [VideoQuality] = []

    VideoQualityMenu(qualities: $qualities, action: { _ in })
}

#Preview("同じ解像度を含む") {
    @Previewable @State var qualities: [VideoQuality] = [
        .init(size: CGSize(width: 1920, height: 1080), averageBitRate: 5_000_000, peakBitRate: 7_000_000),
        .init(size: CGSize(width: 1920, height: 1080), averageBitRate: 3_000_000, peakBitRate: 4_000_000),
        .init(size: CGSize(width: 1280, height: 720), averageBitRate: 2_000_000, peakBitRate: 3_000_000),
    ]

    VideoQualityMenu(qualities: $qualities, action: { _ in })
}
