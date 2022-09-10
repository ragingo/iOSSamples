//
//  CropTestView.swift
//  Sample007-ImageProcessing
//
//  Created by ragingo on 2022/08/28.
//

import SwiftUI
import UIKit

struct CropTestView: View {
    @State private var blocks: [[(Image?)]] = []
    @State private var isHover = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, image in
                        if let image {
                            image
                                .rotation3DEffect(isHover ? .degrees(45) : .zero, axis: (1.0, 1.0, 0))
                                .onHover { value in // iPad だけ使える
                                    withAnimation {
                                        isHover = value
                                    }
                                }
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

    private func onApper() {
        guard let uiImage = UIImage(named: "cat") else {
            return
        }
        guard let cgImage = uiImage.cgImage else {
            assertionFailure("UIImage.cgImage が nil になってるみたい")
            return
        }

        let block_w = 50
        let block_h = 50
        let image_w = cgImage.width
        let image_h = cgImage.height
        var blocks: [[CGImage?]] = []
        var line: [CGImage?] = []

        (0..<image_h/block_h).forEach { block_y in
            (0..<image_w/block_w).forEach { block_x in
                let x = block_x * block_w
                let y = block_y * block_h
                let crop_rect = CGRect(x: x, y: y, width: block_w, height: block_h)
                let cropped_image = cgImage.cropping(to: crop_rect)
                line += [cropped_image]
            }
            blocks += [line]
            line.removeAll(keepingCapacity: true)
        }

        self.blocks = blocks.map { cgImages in
            let images = cgImages.map { cgImage -> Image? in
                if let cgImage {
                    return Image(uiImage: UIImage(cgImage: cgImage))
                }
                return nil
            }
            return images
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CropTestView()
    }
}
