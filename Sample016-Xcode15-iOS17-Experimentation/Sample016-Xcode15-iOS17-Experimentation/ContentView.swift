//
//  ContentView.swift
//  Sample016-Xcode15-iOS17-Experimentation
//
//  Created by ragingo on 2023/07/01.
//

import Foundation
import MyMacro
import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        VStack {
            // “Generate Asset Symbols”
            // (ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS)
            // の実験
            // 設定値を NO にしたらコンパイルエラーになる
            Image(.catman)

            // Strings Catalog の実験
            // SwiftGen みたいにコード生成してくれないのか(T_T)
            Text("Hello, world!")

            // マクロ実装＆呼び出しの実験
            Text("\(#upperCase("abcdefg"))")
        }
        .padding()
    }
}

#Preview("en_US") {
    ContentView()
        .environment(\.locale, .init(identifier: "en_US"))
}

#Preview("ja_JP") {
    ContentView()
        .environment(\.locale, .init(identifier: "ja_JP"))
}

private let base64String = ",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"
