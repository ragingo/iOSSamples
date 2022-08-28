//
//  WebViewWrapper.swift
//  Sample006-WebView
//
//  Created by ragingo on 2022/08/28.
//

import SwiftUI
import WebKit

final class WebViewWrapper: UIViewRepresentable {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(.init(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}
