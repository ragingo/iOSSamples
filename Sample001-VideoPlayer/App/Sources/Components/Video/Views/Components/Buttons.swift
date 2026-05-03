//
//  Untitled.swift
//  VideoPlayer
//
//  Created by ragingo on 2026/05/03.
//

import SwiftUI

struct BackwardButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: "gobackward.10")
            }
        )
    }
}

struct ForwardButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: "goforward.10")
            }
        )
    }
}

struct PlayButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
            }
        )
    }
}

struct LockButton: View {
    let isLocking: Bool
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                isLocking
                    ? Image(systemName: "lock.rotation")
                    : Image(systemName: "lock.rotation.open")
            }
        )
    }
}

struct FlipButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
            }
        )
    }
}
