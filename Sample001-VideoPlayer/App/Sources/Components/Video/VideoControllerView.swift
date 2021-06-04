//
//  VideoControllerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

// プレーヤーコントローラ
struct VideoControllerView: View {
    // スライダ用 (0.0 - 1.0)
    @State private var sliderValue: Double
    // 動画長表示用 (秒)
    @State private var duration: Double
    // 再生位置表示用 (秒)
    @State private var position: Double
    @State private var isPlaying: Bool
    @State private var isSeeking = false
    private let player: VideoPlayerProtocol

    private var sliderMinimumValueLabel: Text {
        Text("\(isSeeking ? sliderValue * duration : position, specifier: "%.0f")")
    }

    private var sliderMaximumValueLabel: Text {
        Text("\(duration, specifier: "%.0f")")
    }

    var body: some View {
        VStack {
            HStack {
                Slider(
                    value: $sliderValue,
                    in: 0...1,
                    onEditingChanged: onSliderEditingChanged,
                    minimumValueLabel: sliderMinimumValueLabel,
                    maximumValueLabel: sliderMaximumValueLabel,
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
        .onReceive(player.positionSubject) { position in
            self.position = position
            // スライダつまみ位置 = 再生位置(秒) / 動画長(秒)
            self.sliderValue = position / self.duration
        }
    }

    init(player: VideoPlayerProtocol) {
        self.sliderValue = .zero
        self.duration = .zero
        self.position = .zero
        self.isPlaying = false
        self.player = player
    }

    private func onSliderEditingChanged(isEditing: Bool) {
        if isEditing {
            isSeeking = true
            pause()
            return
        }
        isSeeking = false
        position = duration * sliderValue
        player.seek(seconds: position) {
            play()
        }
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
