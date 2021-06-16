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

private enum Filter: String, CaseIterable, Identifiable {
    var id: Filter { self }

    case invert = "invert"
    case gaussianBlur = "gaussian blur"
}

// プレーヤーコントローラ
struct VideoControllerView: View {
    // スライダ用 (0.0 - 1.0)
    @State private var sliderValue = 0.0
    // 動画長表示用 (秒)
    @State private var duration = 0.0
    // 再生位置表示用 (秒)
    @State private var position = 0.0
    @State private var loadedBufferRange = (0.0, 0.0)
    @State private var isPlaying = false
    @State private var isSeeking = false
    @State private var isSliderEditing = false
    @State private var isLocking = false
    @State private var selectedRate: RateSteps = .x1_0
    @State private var lockingButtonRotationAngle = 0.0
    @State private var backwardButtonRotationAngle = 0.0
    @State private var forwardButtonRotationAngle = 0.0
    @State private var flipButtonRotationAngle = 0.0
    @State private var isFlip = false
    private var thumbnailPreviewPosition: Binding<Double>
    private var bandwidths: Binding<[Int]>

    @State private var flipFilter: FlipFilter?

    private let player: VideoPlayerProtocol

    private var positionLabel: Text {
        Text(formatTime(seconds: Int(isSliderEditing ? sliderValue * duration : position)))
    }

    private var durationLabel: Text {
        Text(formatTime(seconds: Int(duration)))
    }

    private static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }

    var body: some View {
        VStack {
            VideoSlider(position: $sliderValue, loadedRange: $loadedBufferRange, onThumbDragging: onSliderEditingChanged)
                .onChange(of: $sliderValue.wrappedValue) { _ in
                    if !isSliderEditing {
                        return
                    }
                    thumbnailPreviewPosition.wrappedValue = duration * sliderValue
                }
                .disabled(isLocking)
            HStack {
                positionLabel
                Spacer()
                durationLabel
            }
            HStack {
                Button(action: onLockButtonClicked, label: {
                    isLocking
                        ? Image(systemName: "lock.rotation")
                        : Image(systemName: "lock.rotation.open")
                })
                .rotationEffect(.degrees(lockingButtonRotationAngle))
                .animation(.easeIn, value: lockingButtonRotationAngle)
                .foregroundColor(isLocking ? .red : .primary)

                // 10秒前へ
                Button(action: onGoBackwardButtonClicked, label: {
                    Image(systemName: "gobackward.10")
                })
                .rotationEffect(.degrees(backwardButtonRotationAngle))
                .animation(.easeIn, value: backwardButtonRotationAngle)
                .foregroundColor(.primary)
                .disabled(isLocking)

                // 再生・一時停止
                Button(action: onPlayButtonClicked, label: {
                    isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                })
                .foregroundColor(.primary)
                .disabled(isLocking)

                // 10秒後へ
                Button(action: onGoForwardButtonClicked, label: {
                    Image(systemName: "goforward.10")
                })
                .rotationEffect(.degrees(forwardButtonRotationAngle))
                .animation(.easeIn, value: forwardButtonRotationAngle)
                .foregroundColor(.primary)
                .disabled(isLocking)

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
                .foregroundColor(.primary)
                .disabled(isLocking)

                // 画質(bandwidth)
                if !bandwidths.isEmpty {
                    Menu {
                        ForEach(bandwidths.indices) { i in
                            Button(action: {
                                onBandwidthChanged(value: bandwidths.wrappedValue[i])
                            }, label: {
                                Text(Self.numberFormatter.string(from: NSNumber(value: bandwidths.wrappedValue[i])) ?? "0")
                            })
                        }
                    } label: {
                        Image(systemName: "list.number")
                    }
                    .foregroundColor(.primary)
                    .disabled(isLocking)
                }

                // 左右反転
                Button(action: onFlipButtonCliecked, label: {
                    Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                })
                .rotation3DEffect(.degrees(flipButtonRotationAngle), axis: (x: 0, y: 1, z:0))
                .animation(.easeIn, value: flipButtonRotationAngle)
                .foregroundColor(.primary)
                .disabled(isLocking)

                // フィルター
                Menu {
                    ForEach(Filter.allCases) { filter in
                        Button(action: {
                            onFilterChanged(filter: filter)
                        }, label: {
                            Text(filter.rawValue)
                        })
                    }
                } label: {
                    Text("filter")
                }
                .foregroundColor(.primary)
                .disabled(isLocking)
            }
        }
        .frame(height: 100, alignment: .top)
        .onReceive(player.loadStatusSubject) { status in
            if status == .readyToPlay {
                play()
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
        .onReceive(player.isSeekingSubject) { isSeeking in
            self.isSeeking = isSeeking
            if !isSeeking {
                play()
                // x1.0 に戻るから、記憶している値に戻してやる
                onRateChanged(rate: selectedRate)
            }
        }
        .onReceive(player.loadedBufferRangeSubject) { value in
            let range = (value.0 / duration, value.1 / duration)
            loadedBufferRange = range
        }
    }

    init(player: VideoPlayerProtocol, thumbnailPreviewPosition: Binding<Double>, bandwidths: Binding<[Int]>) {
        self.player = player
        self.thumbnailPreviewPosition = thumbnailPreviewPosition
        self.bandwidths = bandwidths
    }

    private func onSliderEditingChanged(isDragging: Bool, value: Double) {
        if isDragging {
            isSliderEditing = true
            pause()
            return
        }

        isSliderEditing = false
        position = duration * sliderValue
        player.seek(seconds: position)

        player.cancelImageGenerationRequests()
        thumbnailPreviewPosition.wrappedValue = .nan
    }

    private func play() {
        isPlaying = true
        player.play()
    }

    private func pause() {
        isPlaying = false
        player.pause()
    }

    private func onLockButtonClicked() {
        isLocking = !isLocking
        lockingButtonRotationAngle += 360.0
    }

    private func onPlayButtonClicked() {
        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }

    private func onGoBackwardButtonClicked() {
        player.seek(seconds: position - 10)
        backwardButtonRotationAngle -= 360.0
    }

    private func onGoForwardButtonClicked() {
        player.seek(seconds: position + 10)
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

    private func onBandwidthChanged(value: Int) {
        player.changePreferredPeakBitRate(value: value)
    }

    private func onFlipButtonCliecked() {
        isFlip = !isFlip
        flipButtonRotationAngle += 180.0

        if flipFilter == nil {
            flipFilter = FlipFilter()
        }
        if let flipFilter = flipFilter {
            flipFilter.setValue(isFlip, forKey: FlipFilter.Keys.isFlip)
            player.addFilter(filter: flipFilter)
        }
    }

    private func onFilterChanged(filter: Filter) {
        switch filter {
        case .invert:
            if let f = CIFilter(name: "CIColorInvert") {
                player.clearFilters()
                if let flipFilter = flipFilter {
                    flipFilter.setValue(isFlip, forKey: FlipFilter.Keys.isFlip)
                    player.addFilter(filter: flipFilter)
                }
                player.addFilter(filter: f)
            }
        case .gaussianBlur:
            if let f = CIFilter(name: "CIGaussianBlur") {
                player.clearFilters()
                if let flipFilter = flipFilter {
                    flipFilter.setValue(isFlip, forKey: FlipFilter.Keys.isFlip)
                    player.addFilter(filter: flipFilter)
                }
                player.addFilter(filter: f)
            }
        }
    }
}
