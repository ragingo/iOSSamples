//
//  ContentView.swift
//  Sample016-Xcode15-iOS17-Experimentation
//
//  Created by ragingo on 2023/07/01.
//

import SwiftUI

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
