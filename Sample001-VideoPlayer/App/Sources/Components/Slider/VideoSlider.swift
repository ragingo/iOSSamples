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

    private let onThumbDragging: (Double) -> Void
    private let onThumbDragged: (Double) -> Void

    init(position: Binding<Double> = .constant(0),
         loadedRange: Binding<(Double, Double)> = .constant((0, 0)),
         onThumbDragging: @escaping (Double) -> Void = { _ in },
         onThumbDragged: @escaping (Double) -> Void = { _ in }
    ) {
        self.position = position
        self.loadedRange = loadedRange
        self.onThumbDragging = onThumbDragging
        self.onThumbDragged = onThumbDragged
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
                                    baseBarWidth = min(max(value.location.x, 0), proxy.size.width)
                                    onThumbDragging(Double(value.location.x / proxy.size.width))
                                }
                                .onEnded { value in
                                    onThumbDragged(Double(value.location.x / proxy.size.width))
                                }
                    )
            }
            .onAppear {
                updateBaseBarWidth(width: proxy.size.width, ratio: position.wrappedValue)
                updateLoadedBarOffsetX(width: proxy.size.width)
                updateLoadedBarWidth(width: proxy.size.width)
            }
            .onChange(of: position.wrappedValue) { value in
                updateBaseBarWidth(width: proxy.size.width, ratio: value)
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
