//
//  ContentView.swift
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/22.
//

import SwiftUI
import Cpp

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!\(cpp_add(1, 2))")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
