//
//  VideoViewModel.swift
//  App
//
//  Created by ragingo on 2021/06/09.
//

import Combine
import Foundation

final class VideoViewModel: ObservableObject {
    let video: Video

    init(video: Video) {
        self.video = video
    }
}
