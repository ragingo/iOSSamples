//
//  ContentView.swift
//  Sample006-WebView
//
//  Created by ragingo on 2022/08/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if let url = URL(string: "https://www.youtube.com/") {
            WebView(url: url)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
