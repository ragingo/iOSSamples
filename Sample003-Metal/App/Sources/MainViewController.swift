//
//  MainViewController.swift
//  App
//
//  Created by ragingo on 2021/06/21.
//

import UIKit
import MetalKit

class MainViewController: UIViewController, MTKViewDelegate {
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var renderPassDescriptor = MTLRenderPassDescriptor()
    private let vertices: [Float] = [
        -1, -1, 0, 1,
        1, -1, 0, 1,
        -1, 1, 0, 1,
        1, 1, 0, 1
    ]
    private var vertexBuffer: MTLBuffer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // デバイス作成
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()

        if !prepare() {
            return
        }

        let mtkView = MTKView(frame: view.layer.frame, device: device)
        view.addSubview(mtkView)
        mtkView.delegate = self
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        if vertexBuffer == nil {
            let size = vertices.count * MemoryLayout<Float>.size
            vertexBuffer = device.makeBuffer(bytes: vertices, length: size)
        }

        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    private func prepare() -> Bool {
        guard let library = device.makeDefaultLibrary() else { return false }
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: "default_vs")
        renderDesc.fragmentFunction = library.makeFunction(name: "default_fs")
        renderDesc.colorAttachments[0].pixelFormat = .bgra8Unorm

        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderDesc) else {
            return false
        }
        self.renderPipelineState = renderPipelineState

        return true
    }
}
