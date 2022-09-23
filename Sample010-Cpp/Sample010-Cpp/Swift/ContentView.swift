//
//  ContentView.swift
//  Sample010-Cpp
//
//  Created by ragingo on 2022/09/22.
//

import SwiftUI
import Cpp

struct ContentView: View {
    // test images
    // https://dummyimage.com/300x300/ff0000/000000.png&text=png
    // https://dummyimage.com/300x300/00ff00/000000.gif&text=gif
    // https://dummyimage.com/300x300/0000ff/000000.jpg&text=jpg
    // https://picsum.photos/300/300.webp

    private static let imageURL = URL(string: "https://dummyimage.com/200x200/000/fff.gif")!
    @State private var image: Image?
    @State private var mediaType: CppMedia.MediaType?

    var body: some View {
        VStack {
            image
            Text(Self.imageURL.absoluteString)
            Text("format: \(String(describing: mediaType ?? .unknown))")
        }
        .padding()
        .onAppear {
            Task {
                let request = URLRequest(url: Self.imageURL)
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    mediaType = data.withUnsafeBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else {
                            return nil
                        }
                        return CppMedia.RgMedia.getType(baseAddress, data.count)
                    }
                    guard let uiImage = UIImage(data: data) else {
                        return
                    }
                    image = Image(uiImage: uiImage)
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
