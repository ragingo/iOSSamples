//
//  ArtistList.swift
//  Sample009-MusicKit
//
//  Created by ragingo on 2022/09/19.
//

import SwiftUI
import MusicKit

struct ArtistList: View {
    struct Item: Identifiable {
        let id: String
        let name: String
        let artwork: URL?
        let artworkSize: CGSize
    }

    @State private var itemRect: CGRect = .zero

    let items: [Item]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(items) { item in
                    GeometryReader { geo in
                        let frame = geo.frame(in: .global)
                        let isCenter = abs(frame.width / 2 - frame.minX) < 50

                        ArtistView(name: item.name,
                                   artwork: item.artwork,
                                   artworkSize: item.artworkSize)
                        .scaleEffect(isCenter ? 1.1 : 1)
                        .animation(.easeInOut, value: frame)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selection = item.id
                        }
                    }
                    .frame(width: item.artworkSize.width, height: item.artworkSize.height)
                }
            }
            .padding(.vertical, 16) // scaleEffect で膨らむ分空けてみる
        }
    }
}

private struct ItemRectPreferenceKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct ArtistList_Previews: PreviewProvider {
    static var previews: some View {
        let url1: URL? = .init(string: "https://picsum.photos/id/1000/200/200")
        let url2: URL? = .init(string: "https://picsum.photos/id/1002/200/200")
        let url3: URL? = .init(string: "https://picsum.photos/id/1015/200/200")
        let items: [ArtistList.Item] = [
            .init(id: "1", name: "abcde", artwork: url1, artworkSize: .init(width: 200, height: 200)),
            .init(id: "2", name: "fghij", artwork: url2, artworkSize: .init(width: 200, height: 200)),
            .init(id: "3", name: "klmno", artwork: url3, artworkSize: .init(width: 200, height: 200)),
            .init(id: "4", name: "abcde", artwork: url1, artworkSize: .init(width: 200, height: 200)),
            .init(id: "5", name: "fghij", artwork: url2, artworkSize: .init(width: 200, height: 200)),
            .init(id: "6", name: "klmno", artwork: url3, artworkSize: .init(width: 200, height: 200)),
        ]

        ArtistList(items: items, selection: .constant(""))
            .background(.blue.opacity(0.2))
    }
}
