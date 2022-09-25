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
    @State private var imagesDownloadTask: Task<(), Never>?
    @State private var showAlert: Bool = false

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

            Button("cancel") {
                imagesDownloadTask?.cancel()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            imagesDownloadTask = Task {
                do {
                    //try? await Task.sleep(for: .seconds(1000)) // キャンセル確認用

                    let results = try await RgImageLoader.shared.fetchAll(
                        mode: .parallel,
                        urls: Self.imageURLs,
                        cancellationBehavior: .throwError
                    )
                    let infos: [(image: Image, type: CppMedia.MediaType)] = results.compactMap {
                        guard let fetchResult = $0.value else {
                            return nil
                        }
                        let image = Image(uiImage: fetchResult.uiImage)
                        return (image, fetchResult.type)
                    }
                    self.imageInfos = infos
                } catch {
                    print(error)
                    showAlert = true
                }
            }
        }
        .alert("error!", isPresented: $showAlert, actions: {})
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
