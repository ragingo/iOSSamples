//
//  VideoSliderThumb.swift
//  App
//
//  Created by ragingo on 2021/06/07.
//

import SwiftUI

private let defaultWidth: CGFloat = 30
private let defaultHeight: CGFloat = 30
private let defaultShadowRadius: CGFloat = 10

struct VideoSliderThumb: View {
    var body: some View {
        Circle()
            .frame(width: defaultWidth, height: defaultHeight, alignment: .center)
            .shadow(radius: defaultShadowRadius)
    }
}
