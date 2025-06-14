//
//  VideoViewModel.swift
//  App
//
//  Created by ragingo on 2021/06/09.
//

import Combine
import Foundation

@Observable
final class VideoViewModel {
    let video: Video

    init(video: Video) {
        self.video = video
    }
}
