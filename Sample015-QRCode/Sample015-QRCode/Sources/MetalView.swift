//
//  MetalView.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/02/08.
//

import Metal
import UIKit

protocol MetalViewDelegate: AnyObject {
    func onDraw(metalView: MetalView, drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer)
}

class MetalView: UIView {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private(set) var textureCache : CVMetalTextureCache?
    private(set) var metalLayer = CAMetalLayer()
    private var displayLink: CADisplayLink?

    weak var delegate: MetalViewDelegate?

    override init(frame: CGRect) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError()
        }
        self.commandQueue = commandQueue

        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)

        super.init(frame: frame)

        metalLayer.frame = frame
        metalLayer.device = device
        metalLayer.framebufferOnly = false
        metalLayer.drawableSize = frame.size
        layer.addSublayer(metalLayer)

        displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkCallback))
        displayLink?.add(to: .current, forMode: .default)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
    }

    func makeBuffer(bytes: UnsafeRawPointer, length: Int) -> MTLBuffer? {
        return device.makeBuffer(bytes: bytes, length: length)
    }

    func makeRenderCommandEncoder(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        return commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
    }

    func makeRenderPipelineState(pixelFormat: MTLPixelFormat, vertexFunctionName: String, fragmentFunctionName: String) -> MTLRenderPipelineState? {
        guard let library = device.makeDefaultLibrary() else { return nil }
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: vertexFunctionName)
        renderDesc.fragmentFunction = library.makeFunction(name: fragmentFunctionName)
        renderDesc.colorAttachments[0].pixelFormat = pixelFormat
        do {
            return try device.makeRenderPipelineState(descriptor: renderDesc)
        } catch {
            print(error)
            return nil
        }
    }

    @objc private func onDisplayLinkCallback() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        delegate?.onDraw(metalView: self, drawable: drawable, commandBuffer: commandBuffer)
    }
}
