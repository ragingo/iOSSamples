//
//  VideoPlayerView.swift
//  App
//
//  Created by ragingo on 2021/06/03.
//

import Combine
import SwiftUI
import UIKit

// プレーヤ
struct VideoPlayerView: View {
    private static let thumbnailSize = CGSize(width: 200, height: 200)
    private let player: any VideoPlayerProtocol

    @State private var isReady = false
    @State private var isBuffering = false
    @State private var seekThumbnail: Image?
    @State private var thumbnailPreviewPosition: Double = .nan
    @State private var bandwidths: [Int] = []
    @State fileprivate var closedCaption: String = "ここに字幕が表示されます"

    init(player: any VideoPlayerProtocol = VideoPlayer()) {
        self.player = player
    }

    var body: some View {
        ZStack {
            VStack {
                VideoSurfaceView(playerLayer: player.layer)
                    .padding(.horizontal, 8)
                VideoControllerView(
                    player: player,
                    thumbnailPreviewPosition: $thumbnailPreviewPosition,
                    bandwidths: $bandwidths
                )
                .padding(.horizontal, 24)
                .onChange(of: $thumbnailPreviewPosition.wrappedValue) { _, newValue in
                    if newValue.isNaN {
                        seekThumbnail = nil
                        return
                    }
                    player.requestGenerateImage(time: floor(newValue), size: Self.thumbnailSize)
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
        .onReceive(player.generatedImageSubject.receive(on: RunLoop.main)) { (_, cgImage) in
            seekThumbnail = Image(uiImage: UIImage(cgImage: cgImage))
        }
        .onReceive(player.bandwidthsSubject) { value in
            bandwidths = value
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

#Preview {
    let videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    let playerView = VideoPlayerView()

    VStack {
        playerView
    }
    .onAppear {
        playerView.open(urlString: videoURL)
    }
}
