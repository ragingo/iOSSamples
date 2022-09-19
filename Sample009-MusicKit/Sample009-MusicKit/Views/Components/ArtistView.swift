//
//  ArtistView.swift
//  Sample009-MusicKit
//
//  Created by ragingo on 2022/09/19.
//

import SwiftUI

struct ArtistView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    let name: String
    let artwork: URL?
    let artworkSize: CGSize

    var body: some View {
        RgImage(source: .remote(url: artwork))
            .frame(width: artworkSize.width, height: artworkSize.height)
            .cornerRadius(8)
            .shadow(radius: 10)
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Text(name)
                            .font(.title2)
                            .foregroundColor(.white)
                            .lineLimit(3)
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: 2)
            }
    }

    private var borderColor: Color {
        switch colorScheme {
        case .light:
            return .black.opacity(0.5)
        case .dark:
            return .white.opacity(0.5)
        @unknown default:
            return .black.opacity(0.5)
        }
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        let shortName = "a"
        let longName = "artist name artist name artist name artist name artist name"
        let url: URL? = .init(string: "https://picsum.photos/id/1003/500/500")

        ArtistView(name: shortName, artwork: url, artworkSize: .init(width: 200, height: 200))
            .padding()
            .previewLayout(.sizeThatFits)

        ArtistView(name: longName, artwork: url, artworkSize: .init(width: 200, height: 200))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

