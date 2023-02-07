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

struct Rect {
    var x: Float = 0
    var y: Float = 0
    var w: Float = 0
    var h: Float = 0
}

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
    private let vertices: [Float] = [
        -1, -1, +0, +1,
        +1, -1, +0, +1,
        -1, +1, +0, +1,
        +1, +1, +0, +1
    ]
    private let texCoords: [Float] = [
        0, 1,
        1, 1,
        0, 0,
        1, 0
    ]
    private var vertexBuffer: MTLBuffer?
    private var texCoordsBuffer: MTLBuffer?
    private var boundingBoxRect: Rect = .init()
    private var frameBufferData: [Rect] = [.init()]
    private var fragmentBuffer: MTLBuffer?

    private var vertexBufferSize: Int {
        vertices.count * MemoryLayout<Float>.size
    }

    private var texCoordsBufferSize: Int {
        texCoords.count * MemoryLayout<Float>.size
    }

    private var fragmentBufferSize: Int {
        frameBufferData.count * MemoryLayout<Rect>.size
    }

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
        autoResizeDrawable = false

        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexBufferSize)
        texCoordsBuffer = device.makeBuffer(bytes: texCoords, length: texCoordsBufferSize)
        fragmentBuffer = device.makeBuffer(bytes: frameBufferData, length: fragmentBufferSize)
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
            guard let self else { return }
            guard let currentDrawable = self.currentDrawable else { return }
            let scale = self.window?.windowScene?.screen.nativeScale ?? 1.0
            let tex_w = CGFloat(currentDrawable.texture.width) / scale
            let tex_h = CGFloat(currentDrawable.texture.height) / scale
            let rect = CGRect(
                x: tex_w * bounds.origin.x,
                y: tex_h * bounds.origin.x,
                width: tex_w * bounds.width,
                height: tex_h * bounds.height
            )
            self.trackingFrame.frame = rect
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let pixelBuffer, let texture = makeTexture(from: pixelBuffer) else {
            return
        }

        if colorPixelFormat != texture.pixelFormat {
            colorPixelFormat = texture.pixelFormat
        }

        guard let renderPipelineState = makeRenderPipelineState(pixelFormat: texture.pixelFormat) else {
            return
        }

        guard let currentDrawable else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let commandEncoder = makeRenderCommandEncoder(drawable: currentDrawable, commandBuffer: commandBuffer) else {
            return
        }

        guard let fragmentBuffer else { return }
        let fragmentBufferPointer = fragmentBuffer.contents()
        memccpy(fragmentBufferPointer, &boundingBoxRect, 1, fragmentBufferSize)

        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(texCoordsBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentBuffer(fragmentBuffer, offset: 0, index: 1)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    private func makeTexture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        guard let textureCache else { return nil }

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

        guard result == kCVReturnSuccess else { return nil }
        guard let imageTexture else { return nil }
        guard let texture = CVMetalTextureGetTexture(imageTexture) else { return nil }
        return texture
    }

    private func makeRenderCommandEncoder(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].texture = drawable.texture
        desc.colorAttachments[0].loadAction = .clear
        desc.colorAttachments[0].storeAction = .store
        return commandBuffer.makeRenderCommandEncoder(descriptor: desc)
    }

    private func makeRenderPipelineState(pixelFormat: MTLPixelFormat) -> MTLRenderPipelineState? {
        guard let device else { return nil }
        guard let library = device.makeDefaultLibrary() else { return nil }
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: "default_vs")
        renderDesc.fragmentFunction = library.makeFunction(name: "default_fs")
        renderDesc.colorAttachments[0].pixelFormat = pixelFormat
        return try? device.makeRenderPipelineState(descriptor: renderDesc)
    }

    private func drawTextureTest(_ currentDrawable: CAMetalDrawable, _ texture: MTLTexture, _ commandBuffer: MTLCommandBuffer) {
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
    }
}

extension QRCodeReaderView: CodeReaderCameraDelegate {
    func codeReaderCamera(_ camera: CodeReaderCamera, pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didUpdateCorners: [CGPoint]) {
        let a = didUpdateCorners
        boundingBoxRect = Rect(
            x: Float(a[0].x),
            y: Float(a[0].y),
            w: Float(a[2].x),
            h: Float(a[2].y)
        )
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didDetectCode: String) {
        _result.send(didDetectCode)
    }
}

