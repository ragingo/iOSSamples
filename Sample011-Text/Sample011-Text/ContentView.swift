//
//  ContentView.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Kerning") {
                    KerningTestView()
                }
                NavigationLink("Font Features") {
                    FontFeatureTestView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
