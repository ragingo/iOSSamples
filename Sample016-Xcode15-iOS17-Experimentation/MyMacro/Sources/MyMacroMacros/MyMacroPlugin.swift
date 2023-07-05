import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        UpperCaseMacro.self,
        Base64ImageToImageMacro.self,
        Base64ImageToAsciiArtMacro.self
    ]
}
