//
//  FilpFilter.swift
//  App
//
//  Created by ragingo on 2021/06/15.
//

import Foundation
import CoreImage

class FlipFilter: CIFilter {
    private let kernel: CIKernel?
    private var inputImage: CIImage?

    override init() {
        kernel = Self.loadKernel()
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var attributes: [String: Any] {
        return [
            kCIAttributeFilterDisplayName: "Flip Filter",
            kCIInputImageKey: [
                kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage
            ]
        ]
    }

    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case kCIInputImageKey:
            inputImage = value as? CIImage
        default:
            break
        }
    }

    override var outputImage: CIImage? {
        guard let kernel = kernel else { return nil }
        guard let inputImage = inputImage else { return nil }
        let sampler = CISampler(image: inputImage)
        return kernel.apply(extent: inputImage.extent, roiCallback: { _, r in r }, arguments: [sampler])
    }

    private static func loadKernel() -> CIKernel? {
        guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? CIKernel(functionName: "flip", fromMetalLibraryData: data)
    }
}
