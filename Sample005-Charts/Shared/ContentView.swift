//
//  ContentView.swift
//  Shared
//
//  Created by ragingo on 2022/06/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                Text(" 雑な棒グラフ(横向き)")
                makeHorizontalBarChart(geo: geo, maxValue: 100)
                Text(" 雑な棒グラフ(縦向き)")
                makeVerticalBarChart(geo: geo, maxValue: 100)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }

    private func makeShuffledData(range: Range<Int>, count: Int) -> [Int] {
        Array(Array(range).shuffled().prefix(count))
    }

    // 雑な棒グラフ(横向き)
    @ViewBuilder
    private func makeHorizontalBarChart(geo: GeometryProxy, maxValue: Int) -> some View {
        let items = makeShuffledData(range: 1..<100, count: 5)
        let barHeight = 30.0
        let barSpacing = 10.0
        let majorGuidelineCount = 10

        ZStack {
            HStack {
                ForEach(0..<majorGuidelineCount, id: \.self) { index in
                    Spacer()
                        .frame(width: geo.size.width / CGFloat(majorGuidelineCount))
                    Divider()
                        .border(Color.gray, width: 0.1)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: barSpacing) {
                ForEach(items, id: \.self) { item in
                    let length = geo.size.width / CGFloat(maxValue) * CGFloat(item)
                    HStack {
                        Rectangle()
                            .frame(width: CGFloat(length), height: barHeight)
                            .overlay(
                                LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(4)
                    }
                    .overlay(
                        Text("\(item)")
                    )
                }
                Spacer(minLength: 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.2))
        }
    }

    // 雑な棒グラフ(縦向き)
    private func makeVerticalBarChart(geo: GeometryProxy, maxValue: Int) -> some View {
        LazyHStack(alignment: .bottom, spacing: 10) {
            ForEach(makeShuffledData(range: 1..<100, count: 5), id: \.self) { item in
                let length = CGFloat(item)
                VStack {
                    Rectangle()
                        .frame(width: 30, height: length)
                        .overlay(
                            LinearGradient(colors: [.red, .green], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)
                    Text("\(item)")
                }
            }
        }
        .frame(height: 200)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .bottomLeading)
        .background(Color.yellow)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
