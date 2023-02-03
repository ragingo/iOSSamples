//
//  QRCodeReaderView.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/01/26.
//

import UIKit
import AVFoundation
import Combine
import MetalKit
import MetalPerformanceShaders

class QRCodeReaderView: MTKView {
    private let camera: CodeReaderCamera
    private let trackingFrame = UIView()
    private var pixelBuffer: CVPixelBuffer?
    private let ciContext: CIContext
    private let commandQueue: MTLCommandQueue
    private let textureLoader : MTKTextureLoader
    var textureCache : CVMetalTextureCache?
    private let imageTranspose: MPSImageTranspose

    private let _result = PassthroughSubject<String, Never>()
    let result: AnyPublisher<String, Never>

    init(frame: CGRect) {
        camera = .init()
        result = _result
            .removeDuplicates()
            .eraseToAnyPublisher()

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError()
        }
        self.ciContext = CIContext(mtlDevice: device)
        self.textureLoader = MTKTextureLoader(device: device)
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        self.commandQueue = commandQueue
        self.imageTranspose = MPSImageTranspose(device: device)

        super.init(frame: frame, device: device)

        framebufferOnly = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stop()
        camera.videoPreviewLayer?.removeFromSuperlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        camera.videoPreviewLayer?.frame = bounds
    }

    func configure() -> Bool {
        camera.delegate = self

        guard camera.prepare() else {
            return false
        }

        guard let videoPreviewLayer = camera.videoPreviewLayer else {
            return false
        }
        videoPreviewLayer.frame = bounds
//        layer.addSublayer(videoPreviewLayer)

        trackingFrame.layer.borderWidth = 4
        trackingFrame.layer.borderColor = UIColor.systemYellow.cgColor
        trackingFrame.frame = .zero
        addSubview(trackingFrame)

        return true
    }

    func start() {
        camera.startCapture()
    }

    func stop() {
        camera.stopCapture()
    }

    private func updateTrackingFrame(_ bounds: CGRect) {
        DispatchQueue.main.async { [weak self] in
            self?.trackingFrame.frame = bounds
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let pixelBuffer else { return }
        guard let textureCache else { return }
        guard let currentDrawable else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        guard let commandEncoder = commandBuffer.makeBlitCommandEncoder() else {
            return
        }

        var imageTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            CVPixelBufferGetWidth(pixelBuffer),
            CVPixelBufferGetHeight(pixelBuffer),
            0,
            &imageTexture
        )
        guard result == kCVReturnSuccess else { return }
        guard let imageTexture else { return }
        guard let texture = CVMetalTextureGetTexture(imageTexture) else { return }

        if colorPixelFormat != texture.pixelFormat {
            colorPixelFormat = texture.pixelFormat
        }

        let width = min(texture.width, currentDrawable.texture.width)
        let height = min(texture.height, currentDrawable.texture.height)
        commandEncoder.copy(from: texture,
                            sourceSlice: 0,
                            sourceLevel: 0,
                            sourceOrigin: .init(x: 0, y: 0, z: 0),
                            sourceSize: .init(width: width, height: height, depth: texture.depth),
                            to: currentDrawable.texture,
                            destinationSlice: 0,
                            destinationLevel: 0,
                            destinationOrigin: .init(x: abs(currentDrawable.texture.width - width) / 2, y: abs(currentDrawable.texture.height - height) / 2, z: 0))
        commandEncoder.endEncoding()

        // 回転したい場合はこれ(BlitCommandEncoder 不要)
        //imageTranspose.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: currentDrawable.texture)

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

}

extension QRCodeReaderView: CodeReaderCameraDelegate {
    func codeReaderCamera(_ camera: CodeReaderCamera, pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didUpdateBounds: CGRect) {
        updateTrackingFrame(didUpdateBounds)
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didDetectCode: String) {
        _result.send(didDetectCode)
    }
}

