//
//  RgTexture.swift
//  App
//
//  Created by ragingo on 2021/06/26.
//

import CoreGraphics
import Metal

struct RgTexture {
    let mtlTexture: MTLTexture?

    init?(device: MTLDevice, data: Data) {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        let isJpeg = data.starts(with: [0xff, 0xd8])
        let isPng = data.starts(with: [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])

        var image: CGImage?
        if isJpeg {
            image = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        } else if isPng {
            image = CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        }

        guard let image = image else {
            return nil
        }

        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: image.bytesPerRow,
            space: image.colorSpace!,
            bitmapInfo: image.bitmapInfo.rawValue
        ) else {
            return nil
        }

        context.draw(image, in: .init(x: 0, y: 0, width: image.width, height: image.height))

        guard let rawData = context.data else {
            return nil
        }

        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: image.width,
            height: image.height,
            mipmapped: false
        )

        guard let texture = device.makeTexture(descriptor: desc) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, image.width, image.height)
        texture.replace(
            region: region,
            mipmapLevel: 0,
            withBytes: rawData,
            bytesPerRow: image.bytesPerRow
        )

        mtlTexture = texture
    }
}
