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

private struct Rect {
    var x: Float = 0
    var y: Float = 0
    var w: Float = 0
    var h: Float = 0
}

private class Buffers {
    let vertices: [Float] = [
        -1, -1, +0, +1,
        +1, -1, +0, +1,
        -1, +1, +0, +1,
        +1, +1, +0, +1
    ]

    let texCoords: [Float] = [
        0, 1,
        1, 1,
        0, 0,
        1, 0
    ]

    var vertexBuffer: MTLBuffer?
    var texCoordsBuffer: MTLBuffer?
    var boundingBoxRect: Rect = .init()
    var frameBufferData: [Rect] = [.init()]
    var fragmentBuffer: MTLBuffer?

    var vertexBufferSize: Int {
        vertices.count * MemoryLayout<Float>.size
    }

    var texCoordsBufferSize: Int {
        texCoords.count * MemoryLayout<Float>.size
    }

    var fragmentBufferSize: Int {
        frameBufferData.count * MemoryLayout<Rect>.size
    }

    init(metalView: MetalView) {
        vertexBuffer = metalView.makeBuffer(bytes: vertices, length: vertexBufferSize)
        texCoordsBuffer = metalView.makeBuffer(bytes: texCoords, length: texCoordsBufferSize)
        fragmentBuffer = metalView.makeBuffer(bytes: frameBufferData, length: fragmentBufferSize)
    }
}

class QRCodeReaderView: UIView {
    private let metalView: MetalView
    private let buffers: Buffers
    private let camera: CodeReaderCamera
    private var texture: MTLTexture?

    private let _result = PassthroughSubject<String, Never>()
    let result: AnyPublisher<String, Never>

    override init(frame: CGRect) {
        metalView = .init(frame: frame)
        buffers = .init(metalView: metalView)
        camera = .init()
        result = _result
            .removeDuplicates()
            .eraseToAnyPublisher()

        super.init(frame: frame)

        clipsToBounds = true
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.delegate = self
        layer.addSublayer(metalView.layer)
        addSubview(metalView)

        NSLayoutConstraint.activate([
            metalView.centerXAnchor.constraint(equalTo: centerXAnchor),
            metalView.centerYAnchor.constraint(equalTo: centerYAnchor),
            metalView.widthAnchor.constraint(equalTo: widthAnchor),
            metalView.heightAnchor.constraint(equalTo: metalView.widthAnchor, multiplier: 9.0 / 16.0)
        ])
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
        metalView.metalLayer.frame = metalView.bounds
        metalView.metalLayer.drawableSize = .init(
            width: metalView.bounds.size.width * UIScreen.main.nativeScale,
            height: metalView.bounds.size.height * UIScreen.main.nativeScale
        )
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

        return true
    }

    func start() {
        camera.startCapture()
    }

    func stop() {
        camera.stopCapture()
    }
}

extension QRCodeReaderView: CodeReaderCameraDelegate {
    func codeReaderCamera(_ camera: CodeReaderCamera, pixelBuffer: CVPixelBuffer) {
        texture = metalView.makeTexture(from: pixelBuffer, pixelFormat: .bgra8Unorm)
    }

    func codeReaderCamera(_ camera: CodeReaderCamera, didUpdateCorners: [CGPoint]) {
        let a = didUpdateCorners
        buffers.boundingBoxRect = Rect(
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

extension QRCodeReaderView: MetalViewDelegate {
    func onDraw(metalView: MetalView, drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) {
        guard let texture else { return }

        if metalView.metalLayer.pixelFormat != texture.pixelFormat {
            metalView.metalLayer.pixelFormat = texture.pixelFormat
        }

        guard let renderPipelineState = metalView.makeRenderPipelineState(pixelFormat: texture.pixelFormat, vertexFunctionName: "default_vs", fragmentFunctionName: "default_fs") else {
            return
        }

        guard let commandEncoder = metalView.makeRenderCommandEncoder(drawable: drawable, commandBuffer: commandBuffer) else {
            return
        }

        guard let fragmentBuffer = buffers.fragmentBuffer else { return }
        let fragmentBufferPointer = fragmentBuffer.contents()
        memccpy(fragmentBufferPointer, &buffers.boundingBoxRect, 1, buffers.fragmentBufferSize)

        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(buffers.vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(buffers.texCoordsBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentBuffer(fragmentBuffer, offset: 0, index: 1)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
