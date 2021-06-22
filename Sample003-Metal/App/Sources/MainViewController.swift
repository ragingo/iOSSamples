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
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture?

    override func viewDidLoad() {
        super.viewDidLoad()

        // デバイス作成
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()

        let mtkView = MTKView()
        view.addSubview(mtkView)
        mtkView.bounds = view.bounds
        mtkView.device = device
        mtkView.delegate = self
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
        //        mtkView.setNeedsDisplay()

        loadTexture()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }

        // ロードが完了してないなら何もしない
        guard let texture = texture else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let encoder = commandBuffer.makeBlitCommandEncoder() else {
            return
        }

        let width = min(texture.width, drawable.texture.width)
        let height = min(texture.height, drawable.texture.height)

        encoder.copy(
            from: texture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: .init(x: 0, y: 0, z: 0),
            sourceSize: .init(width: width, height: height, depth: texture.depth),
            to: drawable.texture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: .init(x: 0, y: 0, z: 0)
        )
        encoder.endEncoding()

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

            let textureLoader = MTKTextureLoader(device: self.device)
            textureLoader.newTexture(data: data, options: nil) { (texture, error) in
                guard error == nil else { return }
                guard let texture = texture else { return }
                self.texture = texture

                DispatchQueue.main.async {
                    guard let mtkView = self.view.subviews.first as? MTKView else {
                        return
                    }
                    mtkView.colorPixelFormat = texture.pixelFormat
                    mtkView.setNeedsDisplay()
                }
            }
        }
        task.resume()
    }
}
