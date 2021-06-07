//
//  VideoSlider.swift
//  App
//
//  Created by ragingo on 2021/06/07.
//

import SwiftUI

struct VideoSlider: View {
    var position: Binding<Double> = .constant(0)
    var loadedRange: Binding<(Double, Double)> = .constant((0, 0))

    @State private var baseBarWidth: CGFloat = 0
    @State private var loadedBarOffsetX: CGFloat = 0
    @State private var loadedBarWidth: CGFloat = 0
    @State private var isDragging = false

    private let onThumbDragging: (Bool, Double) -> Void

    init(position: Binding<Double> = .constant(0),
         loadedRange: Binding<(Double, Double)> = .constant((0, 0)),
         onThumbDragging: @escaping (Bool, Double) -> Void = { _, _ in }
    ) {
        self.position = position
        self.loadedRange = loadedRange
        self.onThumbDragging = onThumbDragging
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // base
                VideoSliderBar()
                    .foregroundColor(.gray)
                // loaded
                VideoSliderBar()
                    .foregroundColor(.green)
                    .frame(width: loadedBarWidth)
                    .offset(x: loadedBarOffsetX)
                // head - current
                VideoSliderBar()
                    .foregroundColor(.blue)
                    .frame(width: baseBarWidth)
                // thumb
                VideoSliderThumb()
                    .foregroundColor(.white)
                    .offset(x: baseBarWidth - 15.0) // TODO: 動的に thumb の width を取得して 1/2 にしたい
                    .gesture(DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    position.wrappedValue = Double(min(max(value.location.x, 0), proxy.size.width) / proxy.size.width)
                                    onThumbDragging(isDragging, Double(value.location.x / proxy.size.width))
                                }
                                .onEnded { value in
                                    isDragging = false
                                    onThumbDragging(isDragging, Double(value.location.x / proxy.size.width))
                                }
                    )
            }
            .onAppear {
                updateBaseBarWidth(width: proxy.size.width, ratio: position.wrappedValue)
                updateLoadedBarOffsetX(width: proxy.size.width)
                updateLoadedBarWidth(width: proxy.size.width)
            }
            .onChange(of: position.wrappedValue) { value in
                if value.isNaN {
                    return
                }
                updateBaseBarWidth(width: proxy.size.width, ratio: value)
            }
            .onChange(of: loadedRange.0.wrappedValue) { value in
                if value.isNaN {
                    return
                }
                updateLoadedBarOffsetX(width: proxy.size.width)
            }
            .onChange(of: loadedRange.1.wrappedValue) { value in
                if value.isNaN {
                    return
                }
                updateLoadedBarWidth(width: proxy.size.width)
            }
        }
    }

    private func updateBaseBarWidth(width: CGFloat, ratio: Double) {
        baseBarWidth = width * CGFloat(ratio)
    }

    private func updateLoadedBarOffsetX(width: CGFloat) {
        loadedBarOffsetX = width * CGFloat(loadedRange.wrappedValue.0)
    }

    private func updateLoadedBarWidth(width: CGFloat) {
        let range = loadedRange.wrappedValue
        loadedBarWidth = width * CGFloat(range.1 - range.0)
    }
}
