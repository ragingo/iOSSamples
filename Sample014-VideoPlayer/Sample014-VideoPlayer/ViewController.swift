//
//  ViewController.swift
//  Sample014-VideoPlayer
//
//  Created by ragingo on 2023/01/24.
//

import AVFoundation
import UIKit

final class ViewController: UIViewController {
    private static let originalScheme = "https"
    private static let customScheme = "ragingostreaming"
    private static let videoURLString = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
//    private static let videoURLString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

    private var videoURL = URL(string: videoURLString)
    private var player: AVPlayer?
    private var observations: [NSKeyValueObservation] = []

    private var customSchemeURL: URL? {
        guard let videoURL else { return nil }
        return changeScheme(url: videoURL, scheme: Self.customScheme)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observations.forEach {
            $0.invalidate()
        }
    }

    private func setup() {
        guard let videoURL = customSchemeURL else { return }

        let asset = AVURLAsset(url: videoURL)
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        let resourceLoader = asset.resourceLoader
        resourceLoader.setDelegate(self, queue: .main)
        resourceLoader.preloadsEligibleContentKeys = true

        if let item = player?.currentItem {
            let statusObservation = item.observe(\.status, options: [.initial, .new], changeHandler: { [weak self] item, _ in
                guard let self else { return }
                if item.status == .readyToPlay {
                    player?.play()
                }
            })
            observations += [statusObservation]
        }
    }
}

extension ViewController: AVAssetResourceLoaderDelegate {
    struct LoadingError: Error {}

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else {
            loadingRequest.finishLoading(with: LoadingError())
            return false
        }

        guard let originalURL = changeScheme(url: url, scheme: Self.originalScheme) else {
            loadingRequest.finishLoading(with: LoadingError())
            return false
        }

        if originalURL.pathExtension == "m3u8" {
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
            session.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            Task {
                do {
                    let (data, response) = try await session.data(for: .init(url: originalURL))

                    guard let response = response as? HTTPURLResponse else {
                        loadingRequest.finishLoading(with: LoadingError())
                        return
                    }

                    if response.statusCode >= 400 {
                        loadingRequest.finishLoading(with: LoadingError())
                        return
                    }

                    if let request = loadingRequest.contentInformationRequest {
                        request.contentLength = Int64(data.count)
                        request.contentType = response.mimeType
                        request.isByteRangeAccessSupported = true
                    }
                    loadingRequest.dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                } catch {
                    loadingRequest.finishLoading(with: error)
                }
            }
        } else {
            loadingRequest.redirect = loadingRequest.request
            loadingRequest.redirect?.url = originalURL
            loadingRequest.response = HTTPURLResponse(url: originalURL, statusCode: 302, httpVersion: nil, headerFields: nil)
            loadingRequest.finishLoading()
        }

        return true
    }
}

private func changeScheme(url: URL, scheme: String) -> URL? {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        return nil
    }
    components.scheme = scheme
    return components.url
}
