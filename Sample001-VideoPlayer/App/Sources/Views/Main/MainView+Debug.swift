//
//  MainView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/01.
//

import SwiftUI

// 最終的にどういう議論になったかわからないけど、
// 開発用プレビュー機能のはずだから、非 DEBUG ではコンパイルしないようにする。
// https://stackoverflow.com/questions/56485562/are-the-if-debug-statements-really-needed-for-previews-in-swiftui-to-remove-it
#if DEBUG

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

#endif
