//
//  ContentView2.swift
//  Sample007-ImageProcessing
//
//  Created by ragingo on 2022/08/28.
//

import SwiftUI
import UIKit

struct ContentView2: View {
    @State private var blocks: [Int: [(Int, Color)]] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.keys), id: \.self) { row in
                HStack(alignment: .top, spacing: 0) {
                    if let row = blocks[row] {
                        ForEach(row, id: \.0) { id, col in
                            col
                                .frame(width: 2, height: 2)
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(.blue.opacity(0.3))
        .padding()
        .onAppear(perform: onApper)
    }

    // TODO: 表示は壊れてるから、気が向いたら直す
    private func onApper() {
        guard let uiImage = UIImage(named: "cat") else {
            return
        }
        guard let cgImage = uiImage.cgImage else {
            assertionFailure("UIImage.cgImage が nil になってるみたい")
            return
        }
        guard let provider = cgImage.dataProvider else {
            assertionFailure("CGImage.dataProvider が nil になってるみたい")
            return
        }
        guard let bitmap = provider.data else {
            assertionFailure("CGDataProvider.data が nil になってるみたい")
            return
        }
        guard let ptr = CFDataGetBytePtr(bitmap) else {
            assertionFailure("CFDataGetBytePtr(CGDataProvider.data) が nil になってるみたい")
            return
        }

        let scale = 1.0 //UIScreen.main.scale
        let w = Int(CGFloat(cgImage.width) * scale)
        let h = Int(CGFloat(cgImage.height) * scale)
        let componentCount = cgImage.bytesPerRow / w

        // コンポーネント数が 4 の場合のみ処理する
        guard componentCount == 4 else {
            return
        }
        // 各コンポーネントが 8 bit の場合のみ処理する
        guard cgImage.bitsPerComponent == 8 else {
            return
        }
        guard cgImage.bitsPerPixel == cgImage.bitsPerComponent * componentCount else {
            return
        }
        // alpha が最後にある 且つ 乗算済み(premultiplied) の場合のみ処理する
        guard cgImage.alphaInfo == .premultipliedLast else {
            return
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        var blocks: [Int: [(Int, Color)]] = [:]
        var pixels: [(Int, Color)] = []

        (0..<h).forEach { row in
            (0..<w).forEach { col in
                let offset = row * cgImage.bytesPerRow + col * bytesPerPixel
                let r = Double(ptr[offset + 0]) / 255.0
                let g = Double(ptr[offset + 1]) / 255.0
                let b = Double(ptr[offset + 2]) / 255.0
                let a = Double(ptr[offset + 3]) / 255.0
                pixels += [(offset, Color(.sRGB, red: r, green: g, blue: b, opacity: a))]
            }
            blocks[row] = pixels
            pixels.removeAll(keepingCapacity: true)
        }

        self.blocks = blocks
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
