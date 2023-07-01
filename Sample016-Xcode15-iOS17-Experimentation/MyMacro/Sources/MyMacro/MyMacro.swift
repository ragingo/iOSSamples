import SwiftUI

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")

@freestanding(expression)
public macro upperCase(_ string: String) -> String = #externalMacro(module: "MyMacroMacros", type: "UpperCaseMacro")

@freestanding(expression)
public macro base64StringToImage(_ string: String) -> Image = #externalMacro(module: "MyMacroMacros", type: "Base64StringToImageMacro")
