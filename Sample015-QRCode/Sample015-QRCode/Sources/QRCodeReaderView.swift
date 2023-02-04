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
    private let lanczosScale: MPSImageLanczosScale

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
        self.lanczosScale = MPSImageLanczosScale(device: device)

        super.init(frame: frame, device: device)

        framebufferOnly = false
//        autoResizeDrawable = false
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
        videoPreviewLayer.opacity = 0.5
        videoPreviewLayer.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0.5)
        layer.addSublayer(videoPreviewLayer)

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

        commandEncoder.endEncoding()

        // キャンバスよりもテクスチャが小さいなら、短い方をいっぱいまで引き伸ばす
        if currentDrawable.texture.width > texture.width {
            let ratioW = Double(currentDrawable.texture.width) / Double(texture.width)
            let ratioH = Double(currentDrawable.texture.height) / Double(texture.height)
            let ratio = texture.width < texture.height ? ratioH : ratioW

            var scale = MPSScaleTransform(
                scaleX: ratio,
                scaleY: ratio,
                translateX: -((Double(texture.width) * ratio - Double(texture.width)) / 2),
                translateY: 0
            )
            withUnsafePointer(to: &scale) { ptr in
                lanczosScale.scaleTransform = ptr
            }

            lanczosScale.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: currentDrawable.texture)
        } else {
            // まだ未チェック
            let w = min(texture.width, currentDrawable.texture.width)
            let h = min(texture.height, currentDrawable.texture.height)
            let ratioW = Double(w) / Double(texture.width)
            let ratioH = Double(h) / Double(texture.height)
            let ratio = ratioW

            var offset = MPSOffset()

            var scale = MPSScaleTransform(
                scaleX: ratio,
                scaleY: ratio,
                translateX: Double(offset.x),
                translateY: Double(offset.y)
            )
            withUnsafePointer(to: &scale) { ptr in
                lanczosScale.scaleTransform = ptr
            }

            lanczosScale.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: currentDrawable.texture)
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    private func makeTexture2D(pixelFormat: MTLPixelFormat, width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        descriptor.resourceOptions = .storageModeShared
        descriptor.storageMode = .shared
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        return device?.makeTexture(descriptor: descriptor)
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

