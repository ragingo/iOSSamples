//
//  MainViewController.swift
//  App
//
//  Created by ragingo on 2021/06/21.
//

import UIKit
import MetalKit

class MainViewController: UIViewController {
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState?
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture?
    private var renderPassDescriptor = MTLRenderPassDescriptor()
    private let vertices: [Float] = [
        -1, -1, 0, 1,
        1, -1, 0, 1,
        -1, 1, 0, 1,
        1, 1, 0, 1
    ]
    private let texCoords: [Float] = [
        0, 1,
        1, 1,
        0, 0,
        1, 0
    ]

    private var vertexBuffer: MTLBuffer?
    private var texCoordsBuffer: MTLBuffer?
    private let metalLayer = CAMetalLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // デバイス作成
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()

        view.layer.addSublayer(metalLayer)
        metalLayer.frame = view.frame
        metalLayer.device = device
        metalLayer.framebufferOnly = false
        metalLayer.drawableSize = view.bounds.size

        let displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkCallback))
        displayLink.add(to: .current, forMode: .default)

        loadTexture()
    }

    @objc private func onDisplayLinkCallback(displaylink: CADisplayLink) {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let texture = texture else { return }

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        if vertexBuffer == nil {
            let size = vertices.count * MemoryLayout<Float>.size
            vertexBuffer = device.makeBuffer(bytes: vertices, length: size)
        }
        if texCoordsBuffer == nil {
            let size = texCoords.count * MemoryLayout<Float>.size
            texCoordsBuffer = device.makeBuffer(bytes: texCoords, length: size)
        }
        if renderPipelineState == nil {
            guard let library = device.makeDefaultLibrary() else { return }
            let renderDesc = MTLRenderPipelineDescriptor()
            renderDesc.vertexFunction = library.makeFunction(name: "default_vs")
            renderDesc.fragmentFunction = library.makeFunction(name: "default_fs")
            renderDesc.colorAttachments[0].pixelFormat = texture.pixelFormat

            guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderDesc) else {
                return
            }
            self.renderPipelineState = renderPipelineState
        }

        guard let renderPipelineState = renderPipelineState else { return }

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

    private func loadTexture() {
        let urlString = "https://www.pakutaso.com/shared/img/thumb/sakura430-0_TP_V4.jpg"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("ios_metal_test", forHTTPHeaderField: "UserAgent")

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard error == nil else { return }
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                return
            }

            guard let data = data else { return }
            guard let texture = RgTexture(device: self.device, data: data)?.mtlTexture else { return }
            self.texture = texture

            DispatchQueue.main.async {
                self.metalLayer.pixelFormat = texture.pixelFormat
                self.metalLayer.setNeedsDisplay()
            }
        }
        task.resume()
    }
}
