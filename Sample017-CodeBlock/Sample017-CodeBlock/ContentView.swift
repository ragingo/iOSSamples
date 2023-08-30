//
//  ContentView.swift
//  Sample017-CodeBlock
//
//  Created by ragingo on 2023/08/30.
//

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
        ScrollView {
            Text(sourceCode)
                .font(.system(size: 12))
                .padding()
                .task {
                    do {
                        let sourceCode = try await loadSourceCode()
                        self.sourceCode = try processSourceCode(sourceCode, removeComments: true)
                    } catch {
                        sourceCode = AttributedString(String(describing: error))
                        print(error)
                    }
                }
        }
    }
}

func processSourceCode(_ sourceCode: String, removeComments: Bool = false) throws -> AttributedString {
    let lines = sourceCode
        .replacingOccurrences(of: "\r\n", with: "\n")
        .split(separator: "\n")

    var output = ""

    for line in lines {
        if removeComments && line.trimmingPrefix(/( |\t)*/).starts(with: /\/\//) {
            continue
        }
        output += line + "\n"
    }

    let attributedString = NSMutableAttributedString(string: output)

    for info in syntaxHighlightInfos {
        applyColor(attributedString, highlightInfo: info)
    }

    return AttributedString(attributedString)
}

func applyColor(_ attributedString: NSMutableAttributedString, highlightInfo: SyntaxHighlightInfo) {
    if let regex = try? NSRegularExpression(pattern: highlightInfo.kind.pattern) {
        regex.matches(
            in: attributedString.string,
            options: [],
            range: .init(location: 0, length: attributedString.length)
        )
        .forEach {
            attributedString.setAttributes(
                [.foregroundColor: highlightInfo.color],
                range: $0.range
            )
        }
    }
}

enum Kind {
    case comment
    case attribute
    case keyword
    case preprocessor // TODO: swift だと確か違う名前だったから直す

    var pattern: String {
        switch self {
        case .comment:
            return "//.*"
        case .attribute:
            return "@[a-zA-Z_].+"
        case .keyword:
            return "(public|private|internal|let|var|struct|class|func|extension|mutating|return|if|else)([ ]|\t)+"
        case .preprocessor:
            return "(#if|#elseif|#else|#endif).*"
        }
    }
}

struct SyntaxHighlightInfo {
    let kind: Kind
    let color: LegacyColor
}

let syntaxHighlightInfos: [SyntaxHighlightInfo] = [
    .init(kind: .comment, color: .gray),
    .init(kind: .attribute, color: .purple),
    .init(kind: .keyword, color: .systemPink),
    .init(kind: .preprocessor, color: .orange),
]

func loadSourceCode() async throws -> String {
    let request = URLRequest(url: sourceCodeURL)
    let (data, _) = try await URLSession.shared.data(for: request)
    return String(decoding: data, as: UTF8.self)
}

let sourceCodeURL = URL(string: "https://raw.githubusercontent.com/apple/swift/main/stdlib/public/core/Array.swift")!

#Preview {
    ContentView()
}
