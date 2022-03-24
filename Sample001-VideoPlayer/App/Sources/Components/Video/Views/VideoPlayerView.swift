//
//  VideoPlayerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import SwiftUI
import UIKit
import Speech
import Combine

// プレーヤ
struct VideoPlayerView: View {
    private static let thumbnailSize = CGSize(width: 200, height: 200)
    private let player: VideoPlayerProtocol
    private let speechRecognizer: SpeechRecognizer

    @State private var isReady = false
    @State private var isBuffering = false
    @State private var seekThumbnail: Image?
    @State private var thumbnailPreviewPosition: Double = .nan
    @State private var bandwidths: [Int] = []
    @State fileprivate var closedCaption: String = "ここに字幕が表示されます"

    init(player: VideoPlayerProtocol = VideoPlayer()) {
        self.player = player
        speechRecognizer = SpeechRecognizer()
        player.onAudioSampleBufferUpdate = { [self] sampleBuffer in
            speechRecognizer.appendBuffer(sampleBuffer: sampleBuffer)
        }
    }

    var body: some View {
        ZStack {
            VStack {
                VideoSurfaceView(playerLayer: player.layer)
                    .padding(.horizontal, 8)
                VideoControllerView(player: player, thumbnailPreviewPosition: $thumbnailPreviewPosition, bandwidths: $bandwidths)
                    .padding(.horizontal, 24)
                    .onChange(of: $thumbnailPreviewPosition.wrappedValue) { value in
                        if value.isNaN {
                            seekThumbnail = nil
                            return
                        }
                        player.requestGenerateImage(time: floor(value), size: Self.thumbnailSize)
                    }
            }

            Text(closedCaption)
                .foregroundColor(.black)
                .background(.gray.opacity(0.5))
                .padding(.horizontal, 8)

            if !isReady || isBuffering {
                ProgressView()
            }

            HStack(alignment: .center, spacing: nil) {
                // TODO: 適当に表示しているのを直す
                if let seekThumbnail = seekThumbnail {
                    seekThumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200, alignment: .center)
                        .fixedSize()
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            player.prepare()
            speechRecognizer.run()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            player.invalidate()
        }
        .onReceive(player.loadStatusSubject) { status in
            if status == .readyToPlay {
                isReady = true
            }
        }
        .onReceive(player.playStatusSubject) { status in
            isBuffering = status == .buffering
        }
        .onReceive(player.isPlaybackLikelyToKeepUpSubject) { value in
            isBuffering = !value
        }
        .onReceive(player.generatedImageSubject) { (_, cgImage) in
            seekThumbnail = Image(uiImage: UIImage(cgImage: cgImage))
        }
        .onReceive(player.bandwidthsSubject) { value in
            bandwidths = value
        }
        .onReceive(speechRecognizer.partialClosedCaption) { value in
            closedCaption = value
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            player.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            player.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            player.play()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            player.play()
        }
    }

    func open(urlString: String) {
        Task { [weak player] in
            await player?.open(urlString: urlString)
        }
    }
}

class SpeechRecognizer {
    let partialClosedCaption = PassthroughSubject<String, Never>()

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let request: SFSpeechAudioBufferRecognitionRequest
    private var task: SFSpeechRecognitionTask?

    init() {
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // デバイス上で音声認識(インターネット接続しない。インターネット版を使うと毎分リクエストが途切れるから再セットアップ処理が必要。)
        request.requiresOnDeviceRecognition = true
    }

    func run() {
        task = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            guard let self = self else {
                return
            }
            guard let result = result else {
                return
            }
            let text = result.bestTranscription.formattedString
            self.partialClosedCaption.send(text)
        }
    }

    func appendBuffer(sampleBuffer: CMSampleBuffer) {
        request.appendAudioSampleBuffer(sampleBuffer)
    }

}
