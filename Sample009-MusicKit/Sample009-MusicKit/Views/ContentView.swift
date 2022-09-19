//
//  ContentView.swift
//  Sample009-MusicKit
//
//  Created by ragingo on 2022/09/19.
//

import SwiftUI
import MusicKit

// MEMO: MusicKit の検証だから、 MVVM とかやるとしても後回し
struct ContentView: View {
    @State private var musicAuthorizationStatus: MusicAuthorization.Status?
    @State private var searchTerm = ""
    @FocusState private var isSearchTermFocused: Bool
    @State private var isSeaching = false
    @State private var searchResult: MusicCatalogSearchResponse?
    @State private var selectedArtistId = ""
    @State private var currentArtistAlbums: [Album] = []

    var body: some View {
        VStack {
            artistSearchForm

            if let searchResult {
                let items = searchResult.artists.map { artist in
                    ArtistList.Item(id: artist.id.rawValue,
                                    name: artist.name,
                                    artwork: artist.artwork?.url(width: 200, height: 200),
                                    artworkSize: .init(width: 200, height: 200))
                }
                ArtistList(items: items, selection: $selectedArtistId)
            }

            // TODO: コンポーネント化
            List {
                ForEach(currentArtistAlbums) { album in
                    HStack {
                        RgImage(source: .remote(url: album.artwork?.url(width: 200, height: 200)))
                            .frame(width: 200, height: 200)
                            .clipped()
                        Text(album.title)
                            .lineLimit(3)
                    }
                }
            }
            .listStyle(.plain)

            Spacer()
        }
        .overlay {
            VStack {
                if isSeaching {
                    ProgressView()
                        .scaleEffect(2.0)
                }
            }
        }
        .onChange(of: selectedArtistId) { _ in
            guard let searchResult else {
                return
            }
            if let artist = searchResult.artists.first(where: { $0.id.rawValue == selectedArtistId }) {
                Task {
                    do {
                        let updatedArtist = try await artist.with([.albums])
                        if let albums = updatedArtist.albums {
                            self.currentArtistAlbums = albums.map { $0 }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    private var artistSearchForm: some View {
        VStack {
            HStack {
                TextField("アーティスト名を入力してください", text: $searchTerm)
                    .textFieldStyle(.roundedBorder)
                    .focused($isSearchTermFocused)

                Button {
                    onSearchRequestStart(term: searchTerm, types: [Artist.self])
                } label: {
                    searchIcon
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSeaching)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue.opacity(0.2))
    }

    private func onSearchRequestStart(term: String, types: [MusicCatalogSearchable.Type]) {
        Task {
            defer {
                isSeaching = false
            }
            isSearchTermFocused = false
            isSeaching = true
            searchResult = nil

            let request = MusicCatalogSearchRequest(term: term, types: types)
            do {
                searchResult = try await request.response()
            } catch {
                print(error)
            }
        }
    }

    private var searchIcon: Image {
        Image(systemName: "doc.text.magnifyingglass")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
