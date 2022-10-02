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
                Slider(
                    value: $kerning,
                    in: -100.0...100.0,
                    step: 1.0,
                    label: { EmptyView() },
                    minimumValueLabel: { Text("-100") },
                    maximumValueLabel: { Text("100") }
                )
                HStack {
                    Text("\(Int(kerning))")
                }
            }

            makeText(string: "123,456,789", kerning: $kerning, size: 30)
            makeText(string: "Hello, world!", kerning: $kerning, size: 30)
            makeText(string: "Hello,ffilw,123,!=", kerning: $kerning, size: 30)
            makeText(string: "【Hello,ffilw,123,!=】", kerning: $kerning, size: 30)
            makeText(string: "あいう、えお、１２３", kerning: $kerning, size: 30)
            makeText(string: "【あいう、えお、１２３】", kerning: $kerning, size: 30)
            makeText(string: "（あいう、えお、１２３）", kerning: $kerning, size: 30)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func makeText(string: String, kerning: Binding<CGFloat>, size: CGFloat) -> some View {
        if let font = createFont(size: size) {
            Text(string)
                .font(Font(font))
//                .kerning(kerning.wrappedValue)
                .border(.black)
                .background(.blue.opacity(0.2))
        } else {
            Text("(T_T)")
        }
    }

    // https://learn.microsoft.com/ja-jp/typography/opentype/spec/features_pt#tag-palt
    // https://qiita.com/usagimaru/items/0d3c66618df43df93345#ctfontdescriptorcreatecopywithvariation
    //   - iOS は TrueType ベースの Apple Advanced Typography (AAT)
    //   - palt は無い
    // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html
    // https://ics.media/entry/14087/
    //   - iPhone Safari & Chrome で palt が効いているのを確認
    // 【】 について: https://0g0.org/category/3000-303F/1/
    // https://helpx.adobe.com/jp/fonts/using/open-type-syntax.html#palt
    //   - iOS は非対応らしい。ブラウザ側で CoteText で自分で描画しているから palt が効いている？
    // https://qiita.com/usagimaru/items/da88c0a8793f23633c28#nsfont--uifont-%E3%81%A7-font-features-%E3%82%92%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B
    //   - TextEdit.app タイポグラフィーパネルにて全ての「文字間隔」をいじったが、意図した動作をしなかった。
    //     - 「半角」だけ見た目はよさそう。ただ、これを使う場合は隅付き括弧にだけ適用する必要がありそう。
    //     - 「プロポーショナル幅」に期待していたが、全く変化なし

//    private func createFont2(size: CGFloat) -> CTFont? {
//        let featureSettings = [
//            UIFontDescriptor.FeatureKey.type: kSmartSwashType,
//            UIFontDescriptor.FeatureKey.selector: kWordInitialSwashesOnSelector
//        ]
//        guard let font = UIFont(name: "Hiragino Kaku Gothic ProN", size: size) else {
//            return nil
//        }
//        let desc = font.fontDescriptor.addingAttributes([
//            .featureSettings: [
//                [
//                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
//                    UIFontDescriptor.FeatureKey.selector: kProportionalNumbersSelector
//                ]
//            ]
//        ])
//        return UIFont(descriptor: desc, size: size) as CTFont
//    }

    private func createFont(size: CGFloat) -> CTFont? {
        guard let font = CTFontCreateUIFontForLanguage(.user, size, nil) else {
            return nil
        }

        let fontFeatureSettings: [CFDictionary] = [
            [
                kCTFontFeatureTypeIdentifierKey:     kNumberSpacingType,
                kCTFontFeatureSelectorIdentifierKey: kProportionalNumbersSelector
            ] as CFDictionary,
            [
                kCTFontFeatureTypeIdentifierKey:     kTextSpacingType,
                kCTFontFeatureSelectorIdentifierKey: kProportionalTextSelector
            ] as CFDictionary,
            [
                kCTFontFeatureTypeIdentifierKey:     kIdeographicSpacingType,
                kCTFontFeatureSelectorIdentifierKey: kProportionalIdeographsSelector
            ] as CFDictionary,
            [
                kCTFontFeatureTypeIdentifierKey:     kCJKRomanSpacingType,
                kCTFontFeatureSelectorIdentifierKey: kProportionalCJKRomanSelector
            ] as CFDictionary,
        ]

        let fontDescriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontFeatureSettingsAttribute: fontFeatureSettings
        ] as CFDictionary)

        let fontWithFeatures = CTFontCreateCopyWithAttributes(font, size, nil, fontDescriptor)
        return fontWithFeatures
    }
}

struct KerningTestView_Previews: PreviewProvider {
    static var previews: some View {
        KerningTestView()
    }
}
