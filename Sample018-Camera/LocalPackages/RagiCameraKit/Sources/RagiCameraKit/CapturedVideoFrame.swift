//
//  CapturedVideoFrame.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/12.
//

import CoreImage
import CoreGraphics
import CoreMedia
import CoreVideo

public struct CapturedVideoFrame: @unchecked Sendable {
    public let rawBuffer: CMSampleBuffer
    public let pixelBuffer: CVPixelBuffer?
    public let ciImage: CIImage?
    public let cgImage: CGImage?
    private let ciContext: CIContext

    init(ciContext: CIContext, rawBuffer: CMSampleBuffer) {
        self.ciContext = ciContext
        self.rawBuffer = rawBuffer
        self.pixelBuffer = CMSampleBufferGetImageBuffer(rawBuffer)
        self.ciImage = if let pixelBuffer {
            CIImage(cvPixelBuffer: pixelBuffer)
        } else {
            nil
        }
        self.cgImage = if let pixelBuffer, let ciImage {
            ciContext.createCGImage(
                ciImage,
                from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            )
        } else {
            nil
        }
    }
}
