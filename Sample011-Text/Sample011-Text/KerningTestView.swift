//
//  KerningTestView.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/02.
//

import SwiftUI

struct KerningTestView: View {
    @State private var kerning: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Reset") {
                kerning = 0
            }
            .buttonStyle(.bordered)
            .frame(alignment: .center)

            VStack {
                HStack {
                    Text("Kerning: \(Int(kerning))")
                }
                Slider(
                    value: $kerning,
                    in: -100.0...100.0,
                    step: 1.0,
                    label: { EmptyView() },
                    minimumValueLabel: { Text("-100") },
                    maximumValueLabel: { Text("100") }
                )
            }

            makeText(string: "123,456,789", kerning: $kerning, size: 30)
            makeText(string: "Hello, world!", kerning: $kerning, size: 30)
            makeText(string: "Hello,ffilw,123,!=", kerning: $kerning, size: 30)
            makeText(string: "あいうえおかきくけこ", kerning: $kerning, size: 30)
            makeText(string: "あ、い。１２３", kerning: $kerning, size: 30)
            makeText(string: "【あ】い", kerning: $kerning, size: 30)
            makeText(string: "（あ）い", kerning: $kerning, size: 30)
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Kerning")
    }

    @ViewBuilder
    private func makeText(string: String, kerning: Binding<CGFloat>, size: CGFloat) -> some View {
        Text(string)
            .font(.largeTitle)
            .kerning(kerning.wrappedValue)
            .border(.black)
            .background(.blue.opacity(0.2))
    }
}

struct KerningTestView_Previews: PreviewProvider {
    static var previews: some View {
        KerningTestView()
    }
}
