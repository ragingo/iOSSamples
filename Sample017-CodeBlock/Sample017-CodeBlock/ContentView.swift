//
//  ContentView.swift
//  Sample017-CodeBlock
//
//  Created by ragingo on 2023/08/30.
//

import RegexBuilder
import SwiftUI
#if canImport(UIKit)
import UIKit
typealias LegacyColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias LegacyColor = NSColor
#endif

struct ContentView: View {
    @State private var sourceCode: AttributedString = ""

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            // apple/swift/main/stdlib/public/core/Array.swift のテキスト量で描画が完了するのに数秒掛かる
            Text(sourceCode)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(.gray)
                .padding()
                .border(.black)
        }
        .task {
            sourceCode.append(await load())
        }
    }

    private func load() async -> AttributedString {
        do {
            async let task1 = try await loadSourceCode()
            async let task2 = try await loadSyntaxHighlight()
            let (sourceCode, syntaxHighlight) = await (try task1, try task2)
            return try await processSourceCode(
                sourceCode.content,
                fileExtension: sourceCode.extension,
                syntaxHighlight: syntaxHighlight,
                removeComments: false
            )
        } catch {
            return AttributedString(String(describing: error))
        }
    }
}

func processSourceCode(
    _ sourceCode: String,
    fileExtension: String,
    syntaxHighlight: SyntaxHighlight,
    removeComments: Bool = false
) async throws -> AttributedString {
    let output = sourceCode
        .replacingOccurrences(of: "\r\n", with: "\n")
        .split(separator: "\n")
        .filter { line in
            if removeComments && line.trimmingPrefix(/( |\t)*/).starts(with: /\/\//) {
                return false
            }
            return true
        }
        .map { String($0) }
        .joined(separator: "\n")

    let language = syntaxHighlight
        .languages
        .first {
            $0.extension.lowercased() == fileExtension.lowercased()
        }

    guard let language else {
        return AttributedString("")
    }

    var targets: [ColorTarget] = []

    await withTaskGroup(of: [ColorTarget].self) { [output] group in
        for style in language.defaultStyles {
            switch style.key {
            case "keywords":
                let keywords = language.keywords.joined(separator: "|")
                let pattern = "([ ]|\t)+(\(keywords))([ ]|\t)+"
                group.addTask {
                    detectChangeColorTargets(output, pattern: pattern, color: style.legacyColor)
                }
            default:
                break
            }
        }

        for style in language.customStyles {
            group.addTask {
                detectChangeColorTargets(output, pattern: style.pattern, color: style.legacyColor)
            }
        }

        for await result in group {
            targets += result
        }
    }

    let attributedString = NSMutableAttributedString(string: output)

    for target in targets {
        attributedString.addAttribute(
            .foregroundColor,
            value: target.color,
            range: target.range
        )
    }

    return AttributedString(attributedString)
}

struct ColorTarget {
    let range: NSRange
    let color: LegacyColor
}

func detectChangeColorTargets(
    _ string: String,
    pattern: String,
    color: LegacyColor
) -> [ColorTarget] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return []
    }
    return regex.matches(
        in: string,
        options: [],
        range: .init(location: 0, length: string.count)
    )
    .map {
        .init(range: $0.range, color: color)
    }
}

func loadSourceCode() async throws -> (content: String, extension: String) {
    let request = URLRequest(url: sourceCodeURL)
    let (data, _) = try await URLSession.shared.data(for: request)
    let content = String(decoding: data, as: UTF8.self)
    let fileExtension = sourceCodeURL.pathExtension
    return (content, fileExtension)
}

func loadSyntaxHighlight() async throws -> SyntaxHighlight {
    let request = URLRequest(url: syntaxHighlightURL)
    let (data, _) = try await URLSession.shared.data(for: request)
    let decoder = JSONDecoder()
    decoder.allowsJSON5 = true
    return try decoder.decode(SyntaxHighlight.self, from: data)
}

let sourceCodeURL = URL(string: "https://raw.githubusercontent.com/apple/swift/main/stdlib/public/core/Array.swift")!

let syntaxHighlightURL = URL(string: "https://gist.githubusercontent.com/ragingo/662616eea382c183779d25b05f9a1f43/raw/703910b9f9c819935d77be003f5f745543079490/syntaxHighlight.json5")!

struct SyntaxHighlight: Decodable {
    let languages: [Language]
}

struct Language: Decodable {
    let name: String
    let `extension`: String
    let keywords: [String]
    let defaultStyles: [DefaultStyle]
    let customStyles: [CustomStyle]

    struct DefaultStyle: Decodable {
        let key: String
        let color: String

        var legacyColor: LegacyColor {
            return convertLegacyColor(from: color) ?? .black
        }
    }

    struct CustomStyle: Decodable {
        let pattern: String
        let color: String
        let note: String?

        var legacyColor: LegacyColor {
            return convertLegacyColor(from: color) ?? .black
        }
    }
}

func convertLegacyColor(from color: String) -> LegacyColor? {
    let colorRef = Reference(LegacyColor.self)
    let regex = Regex {
        Anchor.startOfLine
        "#"
        Capture(as: colorRef) {
            Repeat(.hexDigit, count: 6)
        } transform: { subString in
            let hex = Int(subString, radix: 16)!
            let r = Double(hex >> 16) / 255.0
            let g = Double((hex >> 8) & 0xff) / 255.0
            let b = Double(hex & 0xff) / 255.0
            return LegacyColor(red: r, green: g, blue: b, alpha: 1.0)
        }
        Anchor.endOfLine
    }

    if let match = try? regex.firstMatch(in: color) {
        return match[colorRef]
    }
    return nil
}

#Preview {
    ContentView()
}
