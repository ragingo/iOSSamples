//
//  VideoControllerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

// プレーヤーコントローラ
struct VideoControllerView: View {
    @State private var duration: Double
    @State private var position: Double
    @State private var isPlaying: Bool
    private let player: VideoPlayerProtocol

    var body: some View {
        VStack {
            HStack {
                Slider(
                    value: $position,
                    in: 0...1,
                    onEditingChanged: onSliderEditingChanged,
                    minimumValueLabel: Text("\(position, specifier: "%.2f")"),
                    maximumValueLabel: Text("\(duration, specifier: "%.0f")"),
                    label: { EmptyView() }
                )
            }
            HStack {
                Button(action: onPlayButtonClicked, label: {
                    isPlaying ? Text("⏸") : Text("▶️")
                })
            }
        }
        .onReceive(player.durationSubject) { duration in
            self.duration = duration
        }
    }

    init(player: VideoPlayerProtocol) {
        self.duration = .zero
        self.position = .zero
        self.isPlaying = false
        self.player = player
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
        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }
}
