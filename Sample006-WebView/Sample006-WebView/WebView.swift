//
//  WebView.swift
//  Sample006-WebView
//
//  Created by ragingo on 2022/08/28.
//

import SwiftUI

struct WebView: View {
    let url: URL

    var body: some View {
        WebViewWrapper(url: url)
    }
}

// プレビューはクラッシュする
//struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        if let url = URL(string: "https://www.youtube.com/") {
//            WebView(url: url)
//        }
//    }
//}
