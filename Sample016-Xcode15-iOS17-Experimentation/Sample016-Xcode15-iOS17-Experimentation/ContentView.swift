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
