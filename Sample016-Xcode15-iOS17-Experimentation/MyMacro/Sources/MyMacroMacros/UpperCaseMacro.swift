//
//  UpperCaseMacro.swift
//
//
//  Created by ragingo on 2023/07/01.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 大文字に変換するマクロ
///
/// 文字列リテラルの引数が1つでないとコンパイルエラーになるようにしている。
///
/// o: #upperCase("abc")
/// x: #upperCase("abc" + "def")
public struct UpperCaseMacro: ExpressionMacro {
    public struct InvalidArgumentError: Error {}

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let expression = node.argumentList.first?.expression else {
            fatalError("compiler bug")
        }

        guard let stringLiteral = expression.as(StringLiteralExprSyntax.self) else {
            throw InvalidArgumentError()
        }

        if stringLiteral.segments.count != 1 {
            throw InvalidArgumentError()
        }

        guard case .stringSegment(let segment) = stringLiteral.segments.first else {
            throw InvalidArgumentError()
        }

        let text = segment.content.text

        return "\(literal: text.uppercased())"
    }
}
