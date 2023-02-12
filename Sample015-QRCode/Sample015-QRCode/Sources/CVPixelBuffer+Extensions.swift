//
//  CVPixelBuffer+Extensions.swift
//  Sample015-QRCode
//
//  Created by ragingo on 2023/02/08.
//

import Foundation
import CoreVideo
import Metal

extension CVPixelBuffer {
    func createMetalTexture(textureCache: CVMetalTextureCache, pixelFormat: MTLPixelFormat) -> MTLTexture? {
        var texture: CVMetalTexture?

        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            self,
            nil,
            pixelFormat,
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            0,
            &texture
        )

        guard result == kCVReturnSuccess else { return nil }
        guard let texture else { return nil }

        return CVMetalTextureGetTexture(texture)
    }
}
