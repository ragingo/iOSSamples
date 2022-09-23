//
//  ContentView.swift
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/22.
//

import SwiftUI
import Cpp

struct ContentView: View {
    private static let imageURLs: [URL] = [
        URL(string: "https://dummyimage.com/300x300/ff0000/000000.png&text=png")!,
        URL(string: "https://dummyimage.com/300x300/00ff00/000000.gif&text=gif")!,
        URL(string: "https://dummyimage.com/300x300/0000ff/000000.jpg&text=jpg")!,
        URL(string: "https://picsum.photos/300/300.webp")!
    ]
    @State private var imageInfos: [(image: Image, type: CppMedia.MediaType)] = []

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<imageInfos.count, id: \.self) { index in
                let info = imageInfos[index]
                HStack {
                    info.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipped()
                    Text("format: \(String(describing: info.type))")
                    Spacer()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            Task {
                let rgImage = RgImage()
                do {
                    let results = try await rgImage.fetchAll(mode: .parallel, urls: Self.imageURLs)
                    let infos: [(image: Image, type: CppMedia.MediaType)] = results.compactMap {
                        guard let fetchResult = $0.value else {
                            return nil
                        }
                        guard let uiImage = UIImage(data: fetchResult.data) else {
                            return nil
                        }
                        let image = Image(uiImage: uiImage)
                        return (image, fetchResult.type)
                    }
                    self.imageInfos = infos
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension CppMedia.MediaType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .invalid:
            return "invalid"
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .gif:
            return "gif"
        case .webp:
            return "webp"
        case .image:
            assertionFailure()
            return ""
        @unknown default:
            return "unknown"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
