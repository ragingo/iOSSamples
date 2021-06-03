//
//  VideoControllerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import AVFoundation
import SwiftUI

// プレーヤーコントローラ
struct VideoControllerView: View {
    private let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    var body: some View {
        HStack {
            Button("play") {
                self.player.play()
            }
        }
    }
}
