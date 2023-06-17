//
//  RootView.swift
//  Sample005-Charts
//
//  Created by ragingo on 2023/06/17.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ScratchChartSampleView()
                .tabItem {
                    Text("自作")
                }
            SwiftUIChartsSampleView()
                .tabItem {
                    Text("SwiftUI Charts")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
