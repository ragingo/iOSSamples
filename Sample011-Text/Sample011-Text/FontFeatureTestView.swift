//
//  FontFeatureTestView.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/03.
//

import SwiftUI

/// MEMO
/// - https://learn.microsoft.com/ja-jp/typography/opentype/spec/features_pt#tag-palt
/// - https://qiita.com/usagimaru/items/0d3c66618df43df93345#ctfontdescriptorcreatecopywithvariation
///   - iOS は TrueType ベースの Apple Advanced Typography (AAT)
///   - palt は無い
/// - https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html
/// - https://ics.media/entry/14087/
///   - iPhone Safari & Chrome で palt が効いているのを確認
/// - 【】 について: https://0g0.org/category/3000-303F/1/
/// - https://helpx.adobe.com/jp/fonts/using/open-type-syntax.html#palt
///   - iOS は非対応らしい。ブラウザ側で CoteText で自分で描画しているから palt が効いている？
/// - https://qiita.com/usagimaru/items/da88c0a8793f23633c28#nsfont--uifont-%E3%81%A7-font-features-%E3%82%92%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B
///   - TextEdit.app タイポグラフィーパネルにて全ての「文字間隔」をいじったが、意図した動作をしなかった。
///     - 「半角」だけ見た目はよさそう。ただ、これを使う場合は隅付き括弧にだけ適用する必要がありそう。
///     - 「プロポーショナル幅」に期待していたが、全く変化なし
///
struct FontFeatureTestView: View {
    @State private var kerning: CGFloat = 0.0
    @State private var selectorsFilter = ""

    @State private var AllTypographicFeatures: FontAllTypographicFeaturesTypeSelectors?
    @State private var AlternateKana: FontAlternateKanaTypeSelectors?
    @State private var Annotation: FontAnnotationTypeSelectors?
    @State private var CaseSensitiveLayout: FontCaseSensitiveLayoutTypeSelectors?
    @State private var CharacterAlternatives: FontCharacterAlternativesTypeSelectors?
    @State private var CharacterShape: FontCharacterShapeTypeSelectors?
    @State private var CJKRomanSpacing: FontCJKRomanSpacingTypeSelectors?
    @State private var CJKSymbolAlternatives: FontCJKSymbolAlternativesTypeSelectors?
    @State private var CJKVerticalRomanPlacement: FontCJKVerticalRomanPlacementTypeSelectors?
    @State private var ContextualAlternates: FontContextualAlternatesTypeSelectors?
    @State private var CursiveConnection: FontCursiveConnectionTypeSelectors?
    @State private var DesignComplexity: FontDesignComplexityTypeSelectors?
    @State private var Diacritics: FontDiacriticsTypeSelectors?
    @State private var Fractions: FontFractionsTypeSelectors?
    @State private var IdeographicAlternatives: FontIdeographicAlternativesTypeSelectors?
    @State private var IdeographicSpacing: FontIdeographicSpacingTypeSelectors?
    @State private var ItalicCJKRoman: FontItalicCJKRomanTypeSelectors?
    @State private var KanaSpacing: FontKanaSpacingTypeSelectors?
    @State private var LetterCase: FontLetterCaseTypeSelectors?
    @State private var Ligatures: FontLigaturesTypeSelectors?
    @State private var LinguisticRearrangement: FontLinguisticRearrangementTypeSelectors?
    @State private var LowerCase: FontLowerCaseTypeSelectors?
    @State private var MathematicalExtras: FontMathematicalExtrasTypeSelectors?
    @State private var NumberCase: FontNumberCaseTypeSelectors?
    @State private var NumberSpacing: FontNumberSpacingTypeSelectors?
    @State private var OrnamentSets: FontOrnamentSetsTypeSelectors?
    @State private var OverlappingCharacters: FontOverlappingCharactersTypeSelectors?
    @State private var RubyKana: FontRubyKanaTypeSelectors?
    @State private var SmartSwash: FontSmartSwashTypeSelectors?
    @State private var StyleOptions: FontStyleOptionsTypeSelectors?
    @State private var StylisticAlternatives: FontStylisticAlternativesTypeSelectors?
    @State private var TextSpacing: FontTextSpacingTypeSelectors?
    @State private var Transliteration: FontTransliterationTypeSelectors?
    @State private var TypographicExtras: FontTypographicExtrasTypeSelectors?
    @State private var UnicodeDecomposition: FontUnicodeDecompositionTypeSelectors?
    @State private var UpperCase: FontUpperCaseTypeSelectors?
    @State private var VerticalPosition: FontVerticalPositionTypeSelectors?
    @State private var VerticalSubstitution: FontVerticalSubstitutionTypeSelectors?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Reset") {
                kerning = 0
                AllTypographicFeatures = nil
                AlternateKana = nil
                Annotation = nil
                CaseSensitiveLayout = nil
                CharacterAlternatives = nil
                CharacterShape = nil
                CJKRomanSpacing = nil
                CJKSymbolAlternatives = nil
                CJKVerticalRomanPlacement = nil
                ContextualAlternates = nil
                CursiveConnection = nil
                DesignComplexity = nil
                Diacritics = nil
                Fractions = nil
                IdeographicAlternatives = nil
                IdeographicSpacing = nil
                ItalicCJKRoman = nil
                KanaSpacing = nil
                LetterCase = nil
                Ligatures = nil
                LinguisticRearrangement = nil
                LowerCase = nil
                MathematicalExtras = nil
                NumberCase = nil
                NumberSpacing = nil
                OrnamentSets = nil
                OverlappingCharacters = nil
                RubyKana = nil
                SmartSwash = nil
                StyleOptions = nil
                StylisticAlternatives = nil
                TextSpacing = nil
                Transliteration = nil
                TypographicExtras = nil
                UnicodeDecomposition = nil
                UpperCase = nil
                VerticalPosition = nil
                VerticalSubstitution = nil
            }
            .buttonStyle(.bordered)
            .frame(alignment: .center)

            Divider()

            VStack(spacing: 4) {
                HStack {
                    Text("Kerning: \(Int(kerning))")
                    Spacer()
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

            Group {
                Divider()
                HStack {
                    Spacer()
                    Text("変更前")
                        .font(.system(size: 20))
                        .border(.black)
                        .background(.orange.opacity(0.2))
                    Text("変更後")
                        .font(.system(size: 20))
                        .border(.black)
                        .background(.blue.opacity(0.2))
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    makeText(string: "123,456,789", kerning: $kerning)
                    makeText(string: "Hello, world!", kerning: $kerning)
                    makeText(string: "ffilw,123,!=", kerning: $kerning)
                    makeText(string: "あいうえおかきくけこ", kerning: $kerning)
                    makeText(string: "【あ】い（う）え、お。", kerning: $kerning)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .background(Color(white: 0.95))

            Divider()
                .frame(height: 2)
                .background(Color.black)

            ScrollView {
                TextField("filter", text: $selectorsFilter)
                    .border(.black)
                    .padding(4)

                makeSelectorSelectionViews()
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Font Features")
    }

    @ViewBuilder
    private func makeText(string: String, kerning: Binding<CGFloat>, size: CGFloat = 20.0) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(string)
                    .kerning(kerning.wrappedValue)
                    .font(.system(size: size))
                    .lineLimit(1)
                    .border(.black)
                    .background(.orange.opacity(0.2))
            }

            HStack {
                if let font = createFont(size: size) {
                    Text(string)
                        .kerning(kerning.wrappedValue)
                        .font(Font(font))
                        .lineLimit(1)
                        .border(.black)
                        .background(.blue.opacity(0.2))
                } else {
                    Text("(T_T)")
                }
            }
        }
    }

    @ViewBuilder
    private func makeSelectorSelectionView<T: RawRepresentable & CaseIterable>(
        _ type: T.Type,
        selectedSelector: Binding<T?>
    ) -> some View where T.RawValue == Int {
        let typeName = "\(type)".replacingOccurrences(of: "Font", with: "").replacingOccurrences(of: "TypeSelectors", with: "")

        if typeName.contains(selectorsFilter) || selectorsFilter.isEmpty {
            VStack(spacing: 0) {
                HStack {
                    Menu(typeName) {
                        let items = enumToMenuItems(type: type)
                        ForEach(items) { item in
                            Button {
                                selectedSelector.wrappedValue = T(rawValue: item.value)
                            } label: {
                                Text("\(item.name): \(item.value)")
                            }
                        }

                        Button {
                            selectedSelector.wrappedValue = nil
                        } label: {
                            Text("disable")
                        }
                    }

                    Spacer()

                    if let selectedSelector = selectedSelector.wrappedValue {
                        let name = "\(selectedSelector)"
                        Text(name)
                    } else {
                        Text("nil")
                    }
                }
            }
            .padding(.horizontal, 8)
            .background(Color(white: 0.95))
            .cornerRadius(4)
            .font(.system(size: 14))
        }
    }

    private func createFont(size: CGFloat) -> CTFont? {
        guard let font = CTFontCreateUIFontForLanguage(.system, size, nil) else {
            return nil
        }

        var fontFeatureSettings: [CFDictionary] = []

        if let AllTypographicFeatures { fontFeatureSettings.append(makeAllTypographicFeaturesType(selector: AllTypographicFeatures)) }
        if let AlternateKana { fontFeatureSettings.append(makeAlternateKanaType(selector: AlternateKana)) }
        if let Annotation { fontFeatureSettings.append(makeAnnotationType(selector: Annotation)) }
        if let CaseSensitiveLayout { fontFeatureSettings.append(makeCaseSensitiveLayoutType(selector: CaseSensitiveLayout)) }
        if let CharacterAlternatives { fontFeatureSettings.append(makeCharacterAlternativesType(selector: CharacterAlternatives)) }
        if let CharacterShape { fontFeatureSettings.append(makeCharacterShapeType(selector: CharacterShape)) }
        if let CJKRomanSpacing { fontFeatureSettings.append(makeCJKRomanSpacingType(selector: CJKRomanSpacing)) }
        if let CJKSymbolAlternatives { fontFeatureSettings.append(makeCJKSymbolAlternativesType(selector: CJKSymbolAlternatives)) }
        if let CJKVerticalRomanPlacement { fontFeatureSettings.append(makeCJKVerticalRomanPlacementType(selector: CJKVerticalRomanPlacement)) }
        if let ContextualAlternates { fontFeatureSettings.append(makeContextualAlternatesType(selector: ContextualAlternates)) }
        if let CursiveConnection { fontFeatureSettings.append(makeCursiveConnectionType(selector: CursiveConnection)) }
        if let DesignComplexity { fontFeatureSettings.append(makeDesignComplexityType(selector: DesignComplexity)) }
        if let Diacritics { fontFeatureSettings.append(makeDiacriticsType(selector: Diacritics)) }
        if let Fractions { fontFeatureSettings.append(makeFractionsType(selector: Fractions)) }
        if let IdeographicAlternatives { fontFeatureSettings.append(makeIdeographicAlternativesType(selector: IdeographicAlternatives)) }
        if let IdeographicSpacing { fontFeatureSettings.append(makeIdeographicSpacingType(selector: IdeographicSpacing)) }
        if let ItalicCJKRoman { fontFeatureSettings.append(makeItalicCJKRomanType(selector: ItalicCJKRoman)) }
        if let KanaSpacing { fontFeatureSettings.append(makeKanaSpacingType(selector: KanaSpacing)) }
        if let LetterCase { fontFeatureSettings.append(makeLetterCaseType(selector: LetterCase)) }
        if let Ligatures { fontFeatureSettings.append(makeLigaturesType(selector: Ligatures)) }
        if let LinguisticRearrangement { fontFeatureSettings.append(makeLinguisticRearrangementType(selector: LinguisticRearrangement)) }
        if let LowerCase { fontFeatureSettings.append(makeLowerCaseType(selector: LowerCase)) }
        if let MathematicalExtras { fontFeatureSettings.append(makeMathematicalExtrasType(selector: MathematicalExtras)) }
        if let NumberCase { fontFeatureSettings.append(makeNumberCaseType(selector: NumberCase)) }
        if let NumberSpacing { fontFeatureSettings.append(makeNumberSpacingType(selector: NumberSpacing)) }
        if let OrnamentSets { fontFeatureSettings.append(makeOrnamentSetsType(selector: OrnamentSets)) }
        if let OverlappingCharacters { fontFeatureSettings.append(makeOverlappingCharactersType(selector: OverlappingCharacters)) }
        if let RubyKana { fontFeatureSettings.append(makeRubyKanaType(selector: RubyKana)) }
        if let SmartSwash { fontFeatureSettings.append(makeSmartSwashType(selector: SmartSwash)) }
        if let StyleOptions { fontFeatureSettings.append(makeStyleOptionsType(selector: StyleOptions)) }
        if let StylisticAlternatives { fontFeatureSettings.append(makeStylisticAlternativesType(selector: StylisticAlternatives)) }
        if let TextSpacing { fontFeatureSettings.append(makeTextSpacingType(selector: TextSpacing)) }
        if let Transliteration { fontFeatureSettings.append(makeTransliterationType(selector: Transliteration)) }
        if let TypographicExtras { fontFeatureSettings.append(makeTypographicExtrasType(selector: TypographicExtras)) }
        if let UnicodeDecomposition { fontFeatureSettings.append(makeUnicodeDecompositionType(selector: UnicodeDecomposition)) }
        if let UpperCase { fontFeatureSettings.append(makeUpperCaseType(selector: UpperCase)) }
        if let VerticalPosition { fontFeatureSettings.append(makeVerticalPositionType(selector: VerticalPosition)) }
        if let VerticalSubstitution { fontFeatureSettings.append(makeVerticalSubstitutionType(selector: VerticalSubstitution)) }

        let fontDescriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontFeatureSettingsAttribute: fontFeatureSettings
        ] as CFDictionary)

        let fontWithFeatures = CTFontCreateCopyWithAttributes(font, size, nil, fontDescriptor)
        return fontWithFeatures
    }

    @ViewBuilder
    private func makeSelectorSelectionViews() -> some View {
        VStack(spacing: 4) {
            Group {
                makeSelectorSelectionView(FontAllTypographicFeaturesTypeSelectors.self, selectedSelector: $AllTypographicFeatures)
                makeSelectorSelectionView(FontAlternateKanaTypeSelectors.self, selectedSelector: $AlternateKana)
                makeSelectorSelectionView(FontAnnotationTypeSelectors.self, selectedSelector: $Annotation)
                makeSelectorSelectionView(FontCaseSensitiveLayoutTypeSelectors.self, selectedSelector: $CaseSensitiveLayout)
                makeSelectorSelectionView(FontCharacterAlternativesTypeSelectors.self, selectedSelector: $CharacterAlternatives)
                makeSelectorSelectionView(FontCharacterShapeTypeSelectors.self, selectedSelector: $CharacterShape)
                makeSelectorSelectionView(FontCJKRomanSpacingTypeSelectors.self, selectedSelector: $CJKRomanSpacing)
                makeSelectorSelectionView(FontCJKSymbolAlternativesTypeSelectors.self, selectedSelector: $CJKSymbolAlternatives)
                makeSelectorSelectionView(FontCJKVerticalRomanPlacementTypeSelectors.self, selectedSelector: $CJKVerticalRomanPlacement)
                makeSelectorSelectionView(FontContextualAlternatesTypeSelectors.self, selectedSelector: $ContextualAlternates)
            }
            Group {
                makeSelectorSelectionView(FontCursiveConnectionTypeSelectors.self, selectedSelector: $CursiveConnection)
                makeSelectorSelectionView(FontDesignComplexityTypeSelectors.self, selectedSelector: $DesignComplexity)
                makeSelectorSelectionView(FontDiacriticsTypeSelectors.self, selectedSelector: $Diacritics)
                makeSelectorSelectionView(FontFractionsTypeSelectors.self, selectedSelector: $Fractions)
                makeSelectorSelectionView(FontIdeographicAlternativesTypeSelectors.self, selectedSelector: $IdeographicAlternatives)
                makeSelectorSelectionView(FontIdeographicSpacingTypeSelectors.self, selectedSelector: $IdeographicSpacing)
                makeSelectorSelectionView(FontItalicCJKRomanTypeSelectors.self, selectedSelector: $ItalicCJKRoman)
                makeSelectorSelectionView(FontKanaSpacingTypeSelectors.self, selectedSelector: $KanaSpacing)
                makeSelectorSelectionView(FontLetterCaseTypeSelectors.self, selectedSelector: $LetterCase)
                makeSelectorSelectionView(FontLigaturesTypeSelectors.self, selectedSelector: $Ligatures)
            }
            Group {
                makeSelectorSelectionView(FontLinguisticRearrangementTypeSelectors.self, selectedSelector: $LinguisticRearrangement)
                makeSelectorSelectionView(FontLowerCaseTypeSelectors.self, selectedSelector: $LowerCase)
                makeSelectorSelectionView(FontMathematicalExtrasTypeSelectors.self, selectedSelector: $MathematicalExtras)
                makeSelectorSelectionView(FontNumberCaseTypeSelectors.self, selectedSelector: $NumberCase)
                makeSelectorSelectionView(FontNumberSpacingTypeSelectors.self, selectedSelector: $NumberSpacing)
                makeSelectorSelectionView(FontOrnamentSetsTypeSelectors.self, selectedSelector: $OrnamentSets)
                makeSelectorSelectionView(FontOverlappingCharactersTypeSelectors.self, selectedSelector: $OverlappingCharacters)
                makeSelectorSelectionView(FontRubyKanaTypeSelectors.self, selectedSelector: $RubyKana)
                makeSelectorSelectionView(FontSmartSwashTypeSelectors.self, selectedSelector: $SmartSwash)
                makeSelectorSelectionView(FontStyleOptionsTypeSelectors.self, selectedSelector: $StyleOptions)
            }
            Group {
                makeSelectorSelectionView(FontStylisticAlternativesTypeSelectors.self, selectedSelector: $StylisticAlternatives)
                makeSelectorSelectionView(FontTextSpacingTypeSelectors.self, selectedSelector: $TextSpacing)
                makeSelectorSelectionView(FontTransliterationTypeSelectors.self, selectedSelector: $Transliteration)
                makeSelectorSelectionView(FontTypographicExtrasTypeSelectors.self, selectedSelector: $TypographicExtras)
                makeSelectorSelectionView(FontUnicodeDecompositionTypeSelectors.self, selectedSelector: $UnicodeDecomposition)
                makeSelectorSelectionView(FontUpperCaseTypeSelectors.self, selectedSelector: $UpperCase)
                makeSelectorSelectionView(FontVerticalPositionTypeSelectors.self, selectedSelector: $VerticalPosition)
                makeSelectorSelectionView(FontVerticalSubstitutionTypeSelectors.self, selectedSelector: $VerticalSubstitution)
            }
        }
    }

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
}

private struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}

private func enumToMenuItems<T: RawRepresentable & CaseIterable>(type: T.Type) -> [MenuItem] where T.RawValue == Int {
    type.allCases.map { MenuItem(name: "\($0)", value: $0.rawValue) }
}

struct FontFeatureTestView_Previews: PreviewProvider {
    static var previews: some View {
        FontFeatureTestView()
    }
}
