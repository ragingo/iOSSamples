//
//  RgImage.swift
//  Sample009-MusicKit
//
//  Created by ragingo on 2022/09/19.
//

import SwiftUI

struct RgImage: View {
    let source: Source

    var body: some View {
        switch source {
        case .image(let image):
            if let image {
                image
                    .resizable()
            } else {
                Rectangle()
            }
        case .remote(let url):
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        }
    }

    private var errorIcon: Image {
        Image(systemName: "xmark.octagon")
            .resizable()
    }
}

extension RgImage {
    enum Source {
        case image(image: Image?)
        case remote(url: URL?)
    }
}

struct RgImage_Previews: PreviewProvider {
    static var previews: some View {
        // 利用サイト: https://picsum.photos/images
        let url: URL? = .init(string: "https://picsum.photos/id/1003/200/200")

        VStack(spacing: 0) {
            RgImage(source: .image(image: nil))
                .frame(width: 200, height: 200)

            RgImage(source: .image(image: Image(systemName: "photo")))
                .frame(width: 200, height: 200)

            RgImage(source: .remote(url: nil))
                .frame(width: 200, height: 200)

            RgImage(source: .remote(url: url))
                .frame(width: 200, height: 200)
        }
        .previewLayout(.sizeThatFits)
    }
}
