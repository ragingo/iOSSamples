//
//  ContentView.swift
//  Sample011-Text
//
//  Created by ragingo on 2022/10/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Kerning") {
                    KerningTestView()
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
