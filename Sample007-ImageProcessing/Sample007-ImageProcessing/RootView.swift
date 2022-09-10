//
//  RootView.swift
//  Sample007-ImageProcessing
//
//  Created by ragingo on 2022/09/10.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            CropTestView()
                .tabItem {
                    Text("Crop")
                }
            Pix2ColorTextView()
                .tabItem {
                    Text("Pix2Color")
                }
            EffectTestView()
                .tabItem {
                    Text("Effect")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
