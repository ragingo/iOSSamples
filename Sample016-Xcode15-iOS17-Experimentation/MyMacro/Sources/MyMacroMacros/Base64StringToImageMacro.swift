//
//  Base64StringToImageMacro.swift
//
//
//  Created by ragingo on 2023/07/02.
//

import Foundation
import SwiftUI
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/**
 呼び出し側で Undefined symbols が出るから一旦諦める。
 Data() は OK だけど Data(base64Encoded:) を使うとこのエラーが出る。

 Undefined symbols for architecture arm64:
   "_$s10Foundation4DataV13base64Encoded7optionsACSgSSh_So6NSDataC21Base64DecodingOptionsVtcfC", referenced from:
       _$s39Sample016_Xcode15_iOS17_Experimentation11ContentViewV4bodyQrvg7SwiftUI05TupleF0VyAE5ImageV_AE4TextVAkItGyXEfU_ in ContentView.o
   "_$s10Foundation4DataV13base64Encoded7optionsACSgSSh_So6NSDataC21Base64DecodingOptionsVtcfcfA0_", referenced from:
       _$s39Sample016_Xcode15_iOS17_Experimentation11ContentViewV4bodyQrvg7SwiftUI05TupleF0VyAE5ImageV_AE4TextVAkItGyXEfU_ in ContentView.o
 ld: symbol(s) not found for architecture arm64
 clang: error: linker command failed with exit code 1 (use -v to see invocation)
 */
public struct Base64StringToImageMacro: ExpressionMacro {
    public struct InvalidArgumentError: Error {
        let message: String
    }

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let expression = node.argumentList.first?.expression else {
            fatalError("compiler bug")
        }

        guard let _ = Data(base64Encoded: expression.description) else {
            throw InvalidArgumentError(message: "base64 decode error")
        }

        //return "Image(uiImage: UIImage(named: \"catman\")!)" // ok
        return "Image(uiImage: UIImage(data: Data(base64Encoded: \(literal: expression.description))!)!)"
    }
}
