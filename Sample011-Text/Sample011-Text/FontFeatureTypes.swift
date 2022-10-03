//
//  FontFeatureTypes.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/03.
//

import Foundation
import CoreText

func makeAllTypographicFeaturesType(selector: FontAllTypographicFeaturesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kAllTypographicFeaturesType, selector: selector.rawValue) }
func makeLigaturesType(selector: FontLigaturesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kLigaturesType, selector: selector.rawValue) }
func makeCursiveConnectionType(selector: FontCursiveConnectionTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCursiveConnectionType, selector: selector.rawValue) }
func makeLetterCaseType(selector: FontLetterCaseTypeSelectors) -> CFDictionary { makeFontFeature(type: .kLetterCaseType, selector: selector.rawValue) }
func makeVerticalSubstitutionType(selector: FontVerticalSubstitutionTypeSelectors) -> CFDictionary { makeFontFeature(type: .kVerticalSubstitutionType, selector: selector.rawValue) }
func makeLinguisticRearrangementType(selector: FontLinguisticRearrangementTypeSelectors) -> CFDictionary { makeFontFeature(type: .kLinguisticRearrangementType, selector: selector.rawValue) }
func makeNumberSpacingType(selector: FontNumberSpacingTypeSelectors) -> CFDictionary { makeFontFeature(type: .kNumberSpacingType, selector: selector.rawValue) }
func makeSmartSwashType(selector: FontSmartSwashTypeSelectors) -> CFDictionary { makeFontFeature(type: .kSmartSwashType, selector: selector.rawValue) }
func makeDiacriticsType(selector: FontDiacriticsTypeSelectors) -> CFDictionary { makeFontFeature(type: .kDiacriticsType, selector: selector.rawValue) }
func makeVerticalPositionType(selector: FontVerticalPositionTypeSelectors) -> CFDictionary { makeFontFeature(type: .kVerticalPositionType, selector: selector.rawValue) }
func makeFractionsType(selector: FontFractionsTypeSelectors) -> CFDictionary { makeFontFeature(type: .kFractionsType, selector: selector.rawValue) }
func makeOverlappingCharactersType(selector: FontOverlappingCharactersTypeSelectors) -> CFDictionary { makeFontFeature(type: .kOverlappingCharactersType, selector: selector.rawValue) }
func makeTypographicExtrasType(selector: FontTypographicExtrasTypeSelectors) -> CFDictionary { makeFontFeature(type: .kTypographicExtrasType, selector: selector.rawValue) }
func makeMathematicalExtrasType(selector: FontMathematicalExtrasTypeSelectors) -> CFDictionary { makeFontFeature(type: .kMathematicalExtrasType, selector: selector.rawValue) }
func makeOrnamentSetsType(selector: FontOrnamentSetsTypeSelectors) -> CFDictionary { makeFontFeature(type: .kOrnamentSetsType, selector: selector.rawValue) }
func makeCharacterAlternativesType(selector: FontCharacterAlternativesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCharacterAlternativesType, selector: selector.rawValue) }
func makeDesignComplexityType(selector: FontDesignComplexityTypeSelectors) -> CFDictionary { makeFontFeature(type: .kDesignComplexityType, selector: selector.rawValue) }
func makeStyleOptionsType(selector: FontStyleOptionsTypeSelectors) -> CFDictionary { makeFontFeature(type: .kStyleOptionsType, selector: selector.rawValue) }
func makeCharacterShapeType(selector: FontCharacterShapeTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCharacterShapeType, selector: selector.rawValue) }
func makeNumberCaseType(selector: FontNumberCaseTypeSelectors) -> CFDictionary { makeFontFeature(type: .kNumberCaseType, selector: selector.rawValue) }
func makeTextSpacingType(selector: FontTextSpacingTypeSelectors) -> CFDictionary { makeFontFeature(type: .kTextSpacingType, selector: selector.rawValue) }
func makeTransliterationType(selector: FontTransliterationTypeSelectors) -> CFDictionary { makeFontFeature(type: .kTransliterationType, selector: selector.rawValue) }
func makeAnnotationType(selector: FontAnnotationTypeSelectors) -> CFDictionary { makeFontFeature(type: .kAnnotationType, selector: selector.rawValue) }
func makeKanaSpacingType(selector: FontKanaSpacingTypeSelectors) -> CFDictionary { makeFontFeature(type: .kKanaSpacingType, selector: selector.rawValue) }
func makeIdeographicSpacingType(selector: FontIdeographicSpacingTypeSelectors) -> CFDictionary { makeFontFeature(type: .kIdeographicSpacingType, selector: selector.rawValue) }
func makeUnicodeDecompositionType(selector: FontUnicodeDecompositionTypeSelectors) -> CFDictionary { makeFontFeature(type: .kUnicodeDecompositionType, selector: selector.rawValue) }
func makeRubyKanaType(selector: FontRubyKanaTypeSelectors) -> CFDictionary { makeFontFeature(type: .kRubyKanaType, selector: selector.rawValue) }
func makeCJKSymbolAlternativesType(selector: FontCJKSymbolAlternativesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCJKSymbolAlternativesType, selector: selector.rawValue) }
func makeIdeographicAlternativesType(selector: FontIdeographicAlternativesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kIdeographicAlternativesType, selector: selector.rawValue) }
func makeCJKVerticalRomanPlacementType(selector: FontCJKVerticalRomanPlacementTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCJKVerticalRomanPlacementType, selector: selector.rawValue) }
func makeItalicCJKRomanType(selector: FontItalicCJKRomanTypeSelectors) -> CFDictionary { makeFontFeature(type: .kItalicCJKRomanType, selector: selector.rawValue) }
func makeCaseSensitiveLayoutType(selector: FontCaseSensitiveLayoutTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCaseSensitiveLayoutType, selector: selector.rawValue) }
func makeAlternateKanaType(selector: FontAlternateKanaTypeSelectors) -> CFDictionary { makeFontFeature(type: .kAlternateKanaType, selector: selector.rawValue) }
func makeStylisticAlternativesType(selector: FontStylisticAlternativesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kStylisticAlternativesType, selector: selector.rawValue) }
func makeContextualAlternatesType(selector: FontContextualAlternatesTypeSelectors) -> CFDictionary { makeFontFeature(type: .kContextualAlternatesType, selector: selector.rawValue) }
func makeLowerCaseType(selector: FontLowerCaseTypeSelectors) -> CFDictionary { makeFontFeature(type: .kLowerCaseType, selector: selector.rawValue) }
func makeUpperCaseType(selector: FontUpperCaseTypeSelectors) -> CFDictionary { makeFontFeature(type: .kUpperCaseType, selector: selector.rawValue) }
func makeCJKRomanSpacingType(selector: FontCJKRomanSpacingTypeSelectors) -> CFDictionary { makeFontFeature(type: .kCJKRomanSpacingType, selector: selector.rawValue) }

func makeFontFeature(type: FontFeatureType, selector: Int) -> CFDictionary {
    [
        kCTFontFeatureTypeIdentifierKey: type.rawValue,
        kCTFontFeatureSelectorIdentifierKey: selector
    ] as CFDictionary
}

// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html

enum FontFeatureType: Int, CaseIterable {
    case kAllTypographicFeaturesType    = 0
    case kLigaturesType                 = 1
    case kCursiveConnectionType         = 2
    case kLetterCaseType                = 3    /* deprecated - use kLowerCaseType or kUpperCaseType instead */
    case kVerticalSubstitutionType      = 4
    case kLinguisticRearrangementType   = 5
    case kNumberSpacingType             = 6
    case kSmartSwashType                = 8
    case kDiacriticsType                = 9
    case kVerticalPositionType          = 10
    case kFractionsType                 = 11
    case kOverlappingCharactersType     = 13
    case kTypographicExtrasType         = 14
    case kMathematicalExtrasType        = 15
    case kOrnamentSetsType              = 16
    case kCharacterAlternativesType     = 17
    case kDesignComplexityType          = 18
    case kStyleOptionsType              = 19
    case kCharacterShapeType            = 20
    case kNumberCaseType                = 21
    case kTextSpacingType               = 22
    case kTransliterationType           = 23
    case kAnnotationType                = 24
    case kKanaSpacingType               = 25
    case kIdeographicSpacingType        = 26
    case kUnicodeDecompositionType      = 27
    case kRubyKanaType                  = 28
    case kCJKSymbolAlternativesType     = 29
    case kIdeographicAlternativesType   = 30
    case kCJKVerticalRomanPlacementType = 31
    case kItalicCJKRomanType            = 32
    case kCaseSensitiveLayoutType       = 33
    case kAlternateKanaType             = 34
    case kStylisticAlternativesType     = 35
    case kContextualAlternatesType      = 36
    case kLowerCaseType                 = 37
    case kUpperCaseType                 = 38
    case kLanguageTagType               = 39
    case kCJKRomanSpacingType           = 103
    case kLastFeatureType               = -1
}

/*
 *    Summary:
 *    Selectors for feature type kAllTypographicFeaturesType
 */
enum FontAllTypographicFeaturesTypeSelectors: Int, CaseIterable {
    case kAllTypeFeaturesOnSelector  = 0
    case kAllTypeFeaturesOffSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kLigaturesType
 */
enum FontLigaturesTypeSelectors: Int, CaseIterable {
    case kRequiredLigaturesOnSelector       = 0
    case kRequiredLigaturesOffSelector      = 1
    case kCommonLigaturesOnSelector         = 2
    case kCommonLigaturesOffSelector        = 3
    case kRareLigaturesOnSelector           = 4
    case kRareLigaturesOffSelector          = 5
    case kLogosOnSelector                   = 6
    case kLogosOffSelector                  = 7
    case kRebusPicturesOnSelector           = 8
    case kRebusPicturesOffSelector          = 9
    case kDiphthongLigaturesOnSelector      = 10
    case kDiphthongLigaturesOffSelector     = 11
    case kSquaredLigaturesOnSelector        = 12
    case kSquaredLigaturesOffSelector       = 13
    case kAbbrevSquaredLigaturesOnSelector  = 14
    case kAbbrevSquaredLigaturesOffSelector = 15
    case kSymbolLigaturesOnSelector         = 16
    case kSymbolLigaturesOffSelector        = 17
    case kContextualLigaturesOnSelector     = 18
    case kContextualLigaturesOffSelector    = 19
    case kHistoricalLigaturesOnSelector     = 20
    case kHistoricalLigaturesOffSelector    = 21
}

/*
 *    Summary:
 *    Selectors for feature type kCursiveConnectionType
 */
enum FontCursiveConnectionTypeSelectors: Int, CaseIterable {
    case kUnconnectedSelector        = 0
    case kPartiallyConnectedSelector = 1
    case kCursiveSelector            = 2
}

/*
 *    Summary:
 *    Selectors for feature type kLetterCaseType
 */
enum FontLetterCaseTypeSelectors: Int, CaseIterable {
    case kUpperAndLowerCaseSelector       = 0    /* deprecated */
    case kAllCapsSelector                 = 1    /* deprecated */
    case kAllLowerCaseSelector            = 2    /* deprecated */
    case kSmallCapsSelector               = 3    /* deprecated */
    case kInitialCapsSelector             = 4    /* deprecated */
    case kInitialCapsAndSmallCapsSelector = 5    /* deprecated */
}

/*
 *    Summary:
 *    Selectors for feature type kVerticalSubstitutionType
 */
enum FontVerticalSubstitutionTypeSelectors: Int, CaseIterable {
    case kSubstituteVerticalFormsOnSelector  = 0
    case kSubstituteVerticalFormsOffSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kLinguisticRearrangementType
 */
enum FontLinguisticRearrangementTypeSelectors: Int, CaseIterable {
    case kLinguisticRearrangementOnSelector  = 0
    case kLinguisticRearrangementOffSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kNumberSpacingType
 */
enum FontNumberSpacingTypeSelectors: Int, CaseIterable {
    case kMonospacedNumbersSelector   = 0
    case kProportionalNumbersSelector = 1
    case kThirdWidthNumbersSelector   = 2
    case kQuarterWidthNumbersSelector = 3
}

/*
 *    Summary:
 *    Selectors for feature type kSmartSwashType
 */
enum FontSmartSwashTypeSelectors: Int, CaseIterable {
    case kWordInitialSwashesOnSelector  = 0
    case kWordInitialSwashesOffSelector = 1
    case kWordFinalSwashesOnSelector    = 2
    case kWordFinalSwashesOffSelector   = 3
    case kLineInitialSwashesOnSelector  = 4
    case kLineInitialSwashesOffSelector = 5
    case kLineFinalSwashesOnSelector    = 6
    case kLineFinalSwashesOffSelector   = 7
    case kNonFinalSwashesOnSelector     = 8
    case kNonFinalSwashesOffSelector    = 9
}

/*
 *    Summary:
 *    Selectors for feature type kDiacriticsType
 */
enum FontDiacriticsTypeSelectors: Int, CaseIterable {
    case kShowDiacriticsSelector      = 0
    case kHideDiacriticsSelector      = 1
    case kDecomposeDiacriticsSelector = 2
}

/*
 *    Summary:
 *    Selectors for feature type kVerticalPositionType
 */
enum FontVerticalPositionTypeSelectors: Int, CaseIterable {
    case kNormalPositionSelector      = 0
    case kSuperiorsSelector           = 1
    case kInferiorsSelector           = 2
    case kOrdinalsSelector            = 3
    case kScientificInferiorsSelector = 4
}

/*
 *    Summary:
 *    Selectors for feature type kFractionsType
 */
enum FontFractionsTypeSelectors: Int, CaseIterable {
    case kNoFractionsSelector       = 0
    case kVerticalFractionsSelector = 1
    case kDiagonalFractionsSelector = 2
}

/*
 *    Summary:
 *    Selectors for feature type kOverlappingCharactersType
 */
enum FontOverlappingCharactersTypeSelectors: Int, CaseIterable {
    case kPreventOverlapOnSelector  = 0
    case kPreventOverlapOffSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kTypographicExtrasType
 */
enum FontTypographicExtrasTypeSelectors: Int, CaseIterable {
    case kHyphensToEmDashOnSelector    = 0
    case kHyphensToEmDashOffSelector   = 1
    case kHyphenToEnDashOnSelector     = 2
    case kHyphenToEnDashOffSelector    = 3
    case kSlashedZeroOnSelector        = 4
    case kSlashedZeroOffSelector       = 5
    case kFormInterrobangOnSelector    = 6
    case kFormInterrobangOffSelector   = 7
    case kSmartQuotesOnSelector        = 8
    case kSmartQuotesOffSelector       = 9
    case kPeriodsToEllipsisOnSelector  = 10
    case kPeriodsToEllipsisOffSelector = 11
}

/*
 *    Summary:
 *    Selectors for feature type kMathematicalExtrasType
 */
enum FontMathematicalExtrasTypeSelectors: Int, CaseIterable {
    case kHyphenToMinusOnSelector        = 0
    case kHyphenToMinusOffSelector       = 1
    case kAsteriskToMultiplyOnSelector   = 2
    case kAsteriskToMultiplyOffSelector  = 3
    case kSlashToDivideOnSelector        = 4
    case kSlashToDivideOffSelector       = 5
    case kInequalityLigaturesOnSelector  = 6
    case kInequalityLigaturesOffSelector = 7
    case kExponentsOnSelector            = 8
    case kExponentsOffSelector           = 9
    case kMathematicalGreekOnSelector    = 10
    case kMathematicalGreekOffSelector   = 11
}

/*
 *    Summary:
 *    Selectors for feature type kOrnamentSetsType
 */
enum FontOrnamentSetsTypeSelectors: Int, CaseIterable {
    case kNoOrnamentsSelector          = 0
    case kDingbatsSelector             = 1
    case kPiCharactersSelector         = 2
    case kFleuronsSelector             = 3
    case kDecorativeBordersSelector    = 4
    case kInternationalSymbolsSelector = 5
    case kMathSymbolsSelector          = 6
}

/*
 *    Summary:
 *    Selectors for feature type kCharacterAlternativesType
 */
enum FontCharacterAlternativesTypeSelectors: Int, CaseIterable {
    case kNoAlternatesSelector = 0
}

/*
 *    Summary:
 *    Selectors for feature type kDesignComplexityType
 */
enum FontDesignComplexityTypeSelectors: Int, CaseIterable {
    case kDesignLevel1Selector = 0
    case kDesignLevel2Selector = 1
    case kDesignLevel3Selector = 2
    case kDesignLevel4Selector = 3
    case kDesignLevel5Selector = 4
}

/*
 *    Summary:
 *    Selectors for feature type kStyleOptionsType
 */
enum FontStyleOptionsTypeSelectors: Int, CaseIterable {
    case kNoStyleOptionsSelector  = 0
    case kDisplayTextSelector     = 1
    case kEngravedTextSelector    = 2
    case kIlluminatedCapsSelector = 3
    case kTitlingCapsSelector     = 4
    case kTallCapsSelector        = 5
}

/*
 *    Summary:
 *    Selectors for feature type kCharacterShapeType
 */
enum FontCharacterShapeTypeSelectors: Int, CaseIterable {
    case kTraditionalCharactersSelector      = 0
    case kSimplifiedCharactersSelector       = 1
    case kJIS1978CharactersSelector          = 2
    case kJIS1983CharactersSelector          = 3
    case kJIS1990CharactersSelector          = 4
    case kTraditionalAltOneSelector          = 5
    case kTraditionalAltTwoSelector          = 6
    case kTraditionalAltThreeSelector        = 7
    case kTraditionalAltFourSelector         = 8
    case kTraditionalAltFiveSelector         = 9
    case kExpertCharactersSelector           = 10
    case kJIS2004CharactersSelector          = 11
    case kHojoCharactersSelector             = 12
    case kNLCCharactersSelector              = 13
    case kTraditionalNamesCharactersSelector = 14
}

/*
 *    Summary:
 *    Selectors for feature type kNumberCaseType
 */
enum FontNumberCaseTypeSelectors: Int, CaseIterable {
    case kLowerCaseNumbersSelector = 0
    case kUpperCaseNumbersSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kTextSpacingType
 */
enum FontTextSpacingTypeSelectors: Int, CaseIterable {
    case kProportionalTextSelector    = 0
    case kMonospacedTextSelector      = 1
    case kHalfWidthTextSelector       = 2
    case kThirdWidthTextSelector      = 3
    case kQuarterWidthTextSelector    = 4
    case kAltProportionalTextSelector = 5
    case kAltHalfWidthTextSelector    = 6
}

/*
 *    Summary:
 *    Selectors for feature type kTransliterationType
 */
enum FontTransliterationTypeSelectors: Int, CaseIterable {
    case kNoTransliterationSelector      = 0
    case kHanjaToHangulSelector          = 1
    case kHiraganaToKatakanaSelector     = 2
    case kKatakanaToHiraganaSelector     = 3
    case kKanaToRomanizationSelector     = 4
    case kRomanizationToHiraganaSelector = 5
    case kRomanizationToKatakanaSelector = 6
    case kHanjaToHangulAltOneSelector    = 7
    case kHanjaToHangulAltTwoSelector    = 8
    case kHanjaToHangulAltThreeSelector  = 9
}

/*
 *    Summary:
 *    Selectors for feature type kAnnotationType
 */
enum FontAnnotationTypeSelectors: Int, CaseIterable {
    case kNoAnnotationSelector                 = 0
    case kBoxAnnotationSelector                = 1
    case kRoundedBoxAnnotationSelector         = 2
    case kCircleAnnotationSelector             = 3
    case kInvertedCircleAnnotationSelector     = 4
    case kParenthesisAnnotationSelector        = 5
    case kPeriodAnnotationSelector             = 6
    case kRomanNumeralAnnotationSelector       = 7
    case kDiamondAnnotationSelector            = 8
    case kInvertedBoxAnnotationSelector        = 9
    case kInvertedRoundedBoxAnnotationSelector = 10
}

/*
 *    Summary:
 *    Selectors for feature type kKanaSpacingType
 */
enum FontKanaSpacingTypeSelectors: Int, CaseIterable {
    case kFullWidthKanaSelector    = 0
    case kProportionalKanaSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kIdeographicSpacingType
 */
enum FontIdeographicSpacingTypeSelectors: Int, CaseIterable {
    case kFullWidthIdeographsSelector    = 0
    case kProportionalIdeographsSelector = 1
    case kHalfWidthIdeographsSelector    = 2
}

/*
 *    Summary:
 *    Selectors for feature type kUnicodeDecompositionType
 */
enum FontUnicodeDecompositionTypeSelectors: Int, CaseIterable {
    case kCanonicalCompositionOnSelector      = 0
    case kCanonicalCompositionOffSelector     = 1
    case kCompatibilityCompositionOnSelector  = 2
    case kCompatibilityCompositionOffSelector = 3
    case kTranscodingCompositionOnSelector    = 4
    case kTranscodingCompositionOffSelector   = 5
}

/*
 *    Summary:
 *    Selectors for feature type kRubyKanaType
 */
enum FontRubyKanaTypeSelectors: Int, CaseIterable {
    case kNoRubyKanaSelector  = 0    /* deprecated - use kRubyKanaOffSelector instead */
    case kRubyKanaSelector    = 1    /* deprecated - use kRubyKanaOnSelector instead */
    case kRubyKanaOnSelector  = 2
    case kRubyKanaOffSelector = 3
}

/*
 *    Summary:
 *    Selectors for feature type kCJKSymbolAlternativesType
 */
enum FontCJKSymbolAlternativesTypeSelectors: Int, CaseIterable {
    case kNoCJKSymbolAlternativesSelector = 0
    case kCJKSymbolAltOneSelector         = 1
    case kCJKSymbolAltTwoSelector         = 2
    case kCJKSymbolAltThreeSelector       = 3
    case kCJKSymbolAltFourSelector        = 4
    case kCJKSymbolAltFiveSelector        = 5
}

/*
 *    Summary:
 *    Selectors for feature type kIdeographicAlternativesType
 */
enum FontIdeographicAlternativesTypeSelectors: Int, CaseIterable {
    case kNoIdeographicAlternativesSelector = 0
    case kIdeographicAltOneSelector         = 1
    case kIdeographicAltTwoSelector         = 2
    case kIdeographicAltThreeSelector       = 3
    case kIdeographicAltFourSelector        = 4
    case kIdeographicAltFiveSelector        = 5
}

/*
 *    Summary:
 *    Selectors for feature type kCJKVerticalRomanPlacementType
 */
enum FontCJKVerticalRomanPlacementTypeSelectors: Int, CaseIterable {
    case kCJKVerticalRomanCenteredSelector  = 0
    case kCJKVerticalRomanHBaselineSelector = 1
}

/*
 *    Summary:
 *    Selectors for feature type kItalicCJKRomanType
 */
enum FontItalicCJKRomanTypeSelectors: Int, CaseIterable {
    case kNoCJKItalicRomanSelector  = 0    /* deprecated - use kCJKItalicRomanOffSelector instead */
    case kCJKItalicRomanSelector    = 1    /* deprecated - use kCJKItalicRomanOnSelector instead */
    case kCJKItalicRomanOnSelector  = 2
    case kCJKItalicRomanOffSelector = 3
}

/*
 *    Summary:
 *    Selectors for feature type kCaseSensitiveLayoutType
 */
enum FontCaseSensitiveLayoutTypeSelectors: Int, CaseIterable {
    case kCaseSensitiveLayoutOnSelector   = 0
    case kCaseSensitiveLayoutOffSelector  = 1
    case kCaseSensitiveSpacingOnSelector  = 2
    case kCaseSensitiveSpacingOffSelector = 3
}

/*
 *    Summary:
 *    Selectors for feature type kAlternateKanaType
 */
enum FontAlternateKanaTypeSelectors: Int, CaseIterable {
    case kAlternateHorizKanaOnSelector  = 0
    case kAlternateHorizKanaOffSelector = 1
    case kAlternateVertKanaOnSelector   = 2
    case kAlternateVertKanaOffSelector  = 3
}

/*
 *    Summary:
 *    Selectors for feature type kStylisticAlternativesType
 */
enum FontStylisticAlternativesTypeSelectors: Int, CaseIterable {
    case kNoStylisticAlternatesSelector = 0
    case kStylisticAltOneOnSelector = 2
    case kStylisticAltOneOffSelector = 3
    case kStylisticAltTwoOnSelector = 4
    case kStylisticAltTwoOffSelector = 5
    case kStylisticAltThreeOnSelector = 6
    case kStylisticAltThreeOffSelector = 7
    case kStylisticAltFourOnSelector = 8
    case kStylisticAltFourOffSelector = 9
    case kStylisticAltFiveOnSelector = 10
    case kStylisticAltFiveOffSelector = 11
    case kStylisticAltSixOnSelector = 12
    case kStylisticAltSixOffSelector = 13
    case kStylisticAltSevenOnSelector = 14
    case kStylisticAltSevenOffSelector = 15
    case kStylisticAltEightOnSelector = 16
    case kStylisticAltEightOffSelector = 17
    case kStylisticAltNineOnSelector = 18
    case kStylisticAltNineOffSelector = 19
    case kStylisticAltTenOnSelector = 20
    case kStylisticAltTenOffSelector = 21
    case kStylisticAltElevenOnSelector = 22
    case kStylisticAltElevenOffSelector = 23
    case kStylisticAltTwelveOnSelector = 24
    case kStylisticAltTwelveOffSelector = 25
    case kStylisticAltThirteenOnSelector = 26
    case kStylisticAltThirteenOffSelector = 27
    case kStylisticAltFourteenOnSelector = 28
    case kStylisticAltFourteenOffSelector = 29
    case kStylisticAltFifteenOnSelector = 30
    case kStylisticAltFifteenOffSelector = 31
    case kStylisticAltSixteenOnSelector = 32
    case kStylisticAltSixteenOffSelector = 33
    case kStylisticAltSeventeenOnSelector = 34
    case kStylisticAltSeventeenOffSelector = 35
    case kStylisticAltEighteenOnSelector = 36
    case kStylisticAltEighteenOffSelector = 37
    case kStylisticAltNineteenOnSelector = 38
    case kStylisticAltNineteenOffSelector = 39
    case kStylisticAltTwentyOnSelector = 40
    case kStylisticAltTwentyOffSelector = 41
}

/*
 *    Summary:
 *    Selectors for feature type kContextualAlternatesType
 */
enum FontContextualAlternatesTypeSelectors: Int, CaseIterable {
    case kContextualAlternatesOnSelector       = 0
    case kContextualAlternatesOffSelector      = 1
    case kSwashAlternatesOnSelector            = 2
    case kSwashAlternatesOffSelector           = 3
    case kContextualSwashAlternatesOnSelector  = 4
    case kContextualSwashAlternatesOffSelector = 5
}

/*
 *    Summary:
 *    Selectors for feature type kLowerCaseType
 */
enum FontLowerCaseTypeSelectors: Int, CaseIterable {
    case kDefaultLowerCaseSelector    = 0
    case kLowerCaseSmallCapsSelector  = 1
    case kLowerCasePetiteCapsSelector = 2
}

/*
 *    Summary:
 *    Selectors for feature type kUpperCaseType
 */
enum FontUpperCaseTypeSelectors: Int, CaseIterable {
    case kDefaultUpperCaseSelector    = 0
    case kUpperCaseSmallCapsSelector  = 1
    case kUpperCasePetiteCapsSelector = 2
}

/*
 *    Summary:
 *    Selectors for feature type kCJKRomanSpacingType
 */
enum FontCJKRomanSpacingTypeSelectors: Int, CaseIterable {
    case kHalfWidthCJKRomanSelector    = 0
    case kProportionalCJKRomanSelector = 1
    case kDefaultCJKRomanSelector      = 2
    case kFullWidthCJKRomanSelector    = 3
}
