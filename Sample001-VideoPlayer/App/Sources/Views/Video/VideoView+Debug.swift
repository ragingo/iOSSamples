//
//  VideoView+Debug.swift
//  App
//
//  Created by ragingo on 2021/06/05.
//

import SwiftUI

#if DEBUG

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(urlString: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    }
}

#endif
