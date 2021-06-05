//
//  VideoControllerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

let secondsPerHour = 3600
let secondsPerMinute = 60

private func formatTime(seconds: Int) -> String {
    let h = seconds / secondsPerHour
    let m = seconds % secondsPerHour / secondsPerMinute
    let s = seconds % secondsPerHour % secondsPerMinute
    return String(format: "%03d:%02d:%02d", h, m, s)
}

private enum RateSteps: String, CaseIterable, Identifiable {
    var id: RateSteps { self }

    case x1_0 = "x 1.0"
    case x1_5 = "x 1.5"
    case x2_0 = "x 2.0"
}

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
    @State private var selectedRate: RateSteps = .x1_0
    @State private var backwardButtonRotationAngle = 0.0
    @State private var forwardButtonRotationAngle = 0.0

    private let player: VideoPlayerProtocol

    private var positionLabel: Text {
        Text(formatTime(seconds: Int(isSeeking ? sliderValue * duration : position)))
    }

    private var durationLabel: Text {
        Text(formatTime(seconds: Int(duration)))
    }

    var body: some View {
        VStack {
            Slider(value: $sliderValue, onEditingChanged: onSliderEditingChanged)
            HStack {
                positionLabel
                Spacer()
                durationLabel
            }
            HStack {
                // 10秒前へ
                Button(action: onGoBackwardButtonClicked, label: {
                    Image(systemName: "gobackward.10")
                })
                .rotationEffect(.degrees(backwardButtonRotationAngle))
                .animation(.easeIn)

                // 再生・一時停止
                Button(action: onPlayButtonClicked, label: {
                    isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                })

                // 10秒後へ
                Button(action: onGoForwardButtonClicked, label: {
                    Image(systemName: "goforward.10")
                })
                .rotationEffect(.degrees(forwardButtonRotationAngle))
                .animation(.easeIn)

                // 再生速度
                Menu {
                    ForEach(RateSteps.allCases) { rate in
                        Button(action: {
                            onRateChanged(rate: rate)
                        }, label: {
                            Text(rate.rawValue)
                        })
                    }
                } label: {
                    Text(selectedRate.rawValue)
                }
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
            // x1.0 に戻るから、記憶している値に戻してやる
            onRateChanged(rate: selectedRate)
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

    private func onGoBackwardButtonClicked() {
        player.seek(seconds: position - 10) {}
        backwardButtonRotationAngle -= 360.0
    }

    private func onGoForwardButtonClicked() {
        player.seek(seconds: position + 10) {}
        forwardButtonRotationAngle += 360.0
    }

    private func onRateChanged(rate: RateSteps) {
        selectedRate = rate
        switch rate {
        case .x1_0:
            player.rate = 1.0
        case .x1_5:
            player.rate = 1.5
        case .x2_0:
            player.rate = 2.0
        }
    }
}
