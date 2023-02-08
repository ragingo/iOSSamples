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
        var imageTexture: CVMetalTexture?

        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            self,
            nil,
            pixelFormat,
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            0,
            &imageTexture
        )

        guard result == kCVReturnSuccess else { return nil }
        guard let imageTexture else { return nil }

        return CVMetalTextureGetTexture(imageTexture)
    }
}
