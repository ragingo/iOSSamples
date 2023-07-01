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

public struct UpperCaseMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug")
        }
        return "\(literal: argument.description.uppercased())"
    }
}
