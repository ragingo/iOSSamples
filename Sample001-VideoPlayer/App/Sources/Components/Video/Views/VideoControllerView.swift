//
//  VideoControllerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI

@const private let secondsPerHour = 3600
@const private let secondsPerMinute = 60

private func formatTime(seconds: Int) -> String {
    let hours = seconds / secondsPerHour
    let minutes = seconds % secondsPerHour / secondsPerMinute
    let seconds = seconds % secondsPerHour % secondsPerMinute
    return unsafe String(format: "%03d:%02d:%02d", hours, minutes, seconds)
}

// swift-format-ignore: AlwaysUseLowerCamelCase
enum VideoRate: String, CaseIterable, Identifiable {
    var id: VideoRate { self }

    case x1_0 = "x 1.0"
    case x1_5 = "x 1.5"
    case x2_0 = "x 2.0"
}

enum VideoFilter: String, CaseIterable, Identifiable {
    var id: VideoFilter { self }

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
    @State private var selectedRate: VideoRate = .x1_0
    @State private var lockingButtonRotationAngle = 0.0
    @State private var backwardButtonRotationAngle = 0.0
    @State private var forwardButtonRotationAngle = 0.0
    @State private var flipButtonRotationAngle = 0.0
    @State private var isFlip = false
    private var thumbnailPreviewPosition: Binding<Double>
    private var bandwidths: Binding<[Int]>

    @State private var flipFilter: FlipFilter?

    private let player: any VideoPlayerProtocol

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

    init(player: any VideoPlayerProtocol, thumbnailPreviewPosition: Binding<Double>, bandwidths: Binding<[Int]>) {
        self.player = player
        self.thumbnailPreviewPosition = thumbnailPreviewPosition
        self.bandwidths = bandwidths
    }

    var body: some View {
        VStack {
            VideoSlider(
                position: $sliderValue,
                loadedRange: $loadedBufferRange,
                onThumbDragging: onSliderEditingChanged
            )
            .onChange(of: $sliderValue.wrappedValue) { _, _ in
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
                LockButton(isLocking: $isLocking, action: onLockButtonClicked)
                    .rotationEffect(.degrees(lockingButtonRotationAngle))
                    .animation(.easeIn, value: lockingButtonRotationAngle)
                    .foregroundColor(isLocking ? .red : .primary)

                // 10秒前へ
                BackwardButton(action: onGoBackwardButtonClicked)
                    .rotationEffect(.degrees(backwardButtonRotationAngle))
                    .animation(.easeIn, value: backwardButtonRotationAngle)
                    .foregroundColor(.primary)
                    .disabled(isLocking)

                // 再生・一時停止
                PlayButton(isPlaying: $isPlaying, action: onPlayButtonClicked)
                    .foregroundColor(.primary)
                    .disabled(isLocking)

                // 10秒後へ
                ForwardButton(action: onGoForwardButtonClicked)
                    .rotationEffect(.degrees(forwardButtonRotationAngle))
                    .animation(.easeIn, value: forwardButtonRotationAngle)
                    .foregroundColor(.primary)
                    .disabled(isLocking)

                // 再生速度
                VideoRateMenu(action: onRateChanged(rate:))
                    .foregroundColor(.primary)
                    .disabled(isLocking)

                // 画質(bandwidth)
                if !bandwidths.isEmpty {
                    VideoQualityMenu(qualities: bandwidths, action: onBandwidthChanged(value:))
                        .foregroundColor(.primary)
                        .disabled(isLocking)
                }

                // 左右反転
                FlipButton(action: onFlipButtonCliecked)
                    .rotation3DEffect(.degrees(flipButtonRotationAngle), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeIn, value: flipButtonRotationAngle)
                    .foregroundColor(.primary)
                    .disabled(isLocking)

                // フィルター
                VideoFilterMenu(action: onFilterChanged(filter:))
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

    private func onSliderEditingChanged(isDragging: Bool, value: Double) {
        if isDragging {
            isSliderEditing = true
            pause()
            return
        }

        isSliderEditing = false
        position = duration * sliderValue
        Task {
            await player.seek(seconds: position)
        }

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
        Task {
            await player.seek(seconds: position - 10)
        }
        backwardButtonRotationAngle -= 360.0
    }

    private func onGoForwardButtonClicked() {
        Task {
            await player.seek(seconds: position + 10)
        }
        forwardButtonRotationAngle += 360.0
    }

    private func onRateChanged(rate: VideoRate) {
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

    private func onFilterChanged(filter: VideoFilter) {
        switch filter {
        case .invert:
            if let ciFilter = CIFilter(name: "CIColorInvert") {
                player.clearFilters()
                if let flipFilter = flipFilter {
                    flipFilter.setValue(isFlip, forKey: FlipFilter.Keys.isFlip)
                    player.addFilter(filter: flipFilter)
                }
                player.addFilter(filter: ciFilter)
            }
        case .gaussianBlur:
            if let ciFilter = CIFilter(name: "CIGaussianBlur") {
                player.clearFilters()
                if let flipFilter = flipFilter {
                    flipFilter.setValue(isFlip, forKey: FlipFilter.Keys.isFlip)
                    player.addFilter(filter: flipFilter)
                }
                player.addFilter(filter: ciFilter)
            }
        }
    }
}

#Preview {
    let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    let player = VideoPlayer()

    VideoControllerView(
        player: player,
        thumbnailPreviewPosition: .constant(0),
        bandwidths: .constant([1, 2, 3])
    )
    .onAppear {
        Task {
            await player.open(urlString: videoURL)
        }
    }
}
