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
    @Binding private(set) var position: Double
    @State private var isPlaying: Bool = false
    let player: AVPlayer

    var body: some View {
        VStack {
            HStack {
                Slider(value: $position, onEditingChanged: onSliderEditingChanged)
            }
            HStack {
                Button(action: onPlayButtonClicked, label: {
                    isPlaying ? Text("⏸") : Text("▶️")
                })
            }
        }
    }

    private func onSliderEditingChanged(isEditing: Bool) {
        if isEditing {
            pause()
            return
        }

        play()
    }

    private func play() {
        isPlaying = true
        player.play()
    }

    private func pause() {
        isPlaying = false
        player.pause()
    }

    private func onPlayButtonClicked() {
        if player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            pause()
        } else {
            play()
        }
    }
}
