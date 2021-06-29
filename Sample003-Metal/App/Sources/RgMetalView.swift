//
//  RgMetalView.swift
//  App
//
//  Created by ragingo on 2021/06/29.
//

import Foundation
import UIKit

class RgMetalView: UIView {
    private let metalLayer = CAMetalLayer()
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState?
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture?
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

    private var vertexBufferSize: Int {
        vertices.count * MemoryLayout<Float>.size
    }

    private var texCoordsBufferSize: Int {
        texCoords.count * MemoryLayout<Float>.size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // デバイス作成
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()

        // レイヤ作成
        layer.addSublayer(metalLayer)
        metalLayer.frame = frame
        metalLayer.device = device
        metalLayer.framebufferOnly = false
        metalLayer.drawableSize = bounds.size

        // DisplayLink 作成
        let displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkCallback))
        displayLink.add(to: .current, forMode: .default)

        // テクスチャのロード
        loadTexture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onDisplayLinkCallback(displaylink: CADisplayLink) {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexBufferSize) else {
            return
        }

        guard let texCoordsBuffer = device.makeBuffer(bytes: texCoords, length: texCoordsBufferSize) else {
            return
        }

        guard let texture = texture else { return }

        guard let renderPipelineState = makeRenderPipelineState(pixelFormat: texture.pixelFormat) else {
            return
        }

        guard let renderEncoder = makeRenderCommandEncoder(drawable: drawable, commandBuffer: commandBuffer) else {
            return
        }

        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(texCoordsBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    private func makeRenderCommandEncoder(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].texture = drawable.texture
        desc.colorAttachments[0].loadAction = .clear
        desc.colorAttachments[0].storeAction = .store
        return commandBuffer.makeRenderCommandEncoder(descriptor: desc)
    }

    private func makeRenderPipelineState(pixelFormat: MTLPixelFormat) -> MTLRenderPipelineState? {
        guard let library = device.makeDefaultLibrary() else { return nil }
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: "default_vs")
        renderDesc.fragmentFunction = library.makeFunction(name: "default_fs")
        renderDesc.colorAttachments[0].pixelFormat = pixelFormat
        return try? device.makeRenderPipelineState(descriptor: renderDesc)
    }

    private func loadTexture() {
        let urlString = "https://www.pakutaso.com/shared/img/thumb/sakura430-0_TP_V4.jpg"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("ios_metal_test", forHTTPHeaderField: "UserAgent")

        RgTextureLoader.load(request: request, device: device) { [weak self] texture in
            guard let self = self else { return }
            guard let texture = texture?.mtlTexture else { return }
            self.texture = texture

            DispatchQueue.main.async {
                self.metalLayer.pixelFormat = texture.pixelFormat
                self.metalLayer.setNeedsDisplay()
            }
        }
    }

}
