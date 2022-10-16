//
//  CoreTextTestView.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/16.
//

import CoreGraphics
import CoreText
import SwiftUI

struct CoreTextTestView: View {
    var body: some View {
        Canvas { context, size in
            context.withCGContext(content: { cgContext in
                drawText(context: cgContext, size: size, text: "【あ】（い）「う」え、お。\nあいうえお")
            })
        }
    }

    private func drawText(context: CGContext, size: CGSize, text: String) {
        guard let attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0) else {
            return
        }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -size.height)
        let path = CGPath(rect: .init(origin: .zero, size: size), transform: nil)
        CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0), text as CFString)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        CTFrameDraw(frame, context)
    }
}

struct CoreTextTestView_Previews: PreviewProvider {
    static var previews: some View {
        CoreTextTestView()
    }
}
