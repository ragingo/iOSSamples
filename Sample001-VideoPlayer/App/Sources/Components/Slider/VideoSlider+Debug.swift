//
//  VideoSlider+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/07.
//

import SwiftUI

#if DEBUG

struct VideoSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            VideoSlider(
                position: .constant(0.5),
                loadedRange: .constant((0.3, 0.7))
            )
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
    }
}

#endif
