//
//  Expander.swift
//  Sample007-ImageProcessing
//
//  Created by ragingo on 2022/09/10.
//

import SwiftUI

struct Expander<Title: View, Content: View>: View {
    private let title: () -> Title
    private let content: () -> Content

    @State private var isExpanded = false

    init(@ViewBuilder title: @escaping () -> Title,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            ExpanderHeader(title: title, isExpanded: $isExpanded)

            Divider()
                .padding(.vertical, 8)

            VStack(spacing: 0) {
                content()
                    .frame(maxHeight: isExpanded ? nil : 0)
                    .clipped()
            }
        }
    }
}

struct ExpanderHeader<Title: View>: View {
    private let title: () -> Title
    private let isExpanded: Binding<Bool>

    @State private var buttonAngle = 0.0

    init(@ViewBuilder title: @escaping () -> Title, isExpanded: Binding<Bool>) {
        self.title = title
        self.isExpanded = isExpanded
    }

    var body: some View {
        HStack {
            title()
            Spacer()
            Button {
                isExpanded.wrappedValue.toggle()
                buttonAngle = isExpanded.wrappedValue ? 90.0 : 0.0
            } label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(buttonAngle))
            }
        }
    }
}

struct Expander_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Expander(
                title: {
                    Text("header")
                },
                content: {
                    VStack {
                    }
                    .frame(width: 300, height: 300)
                    .background(.blue.opacity(0.5))
                }
            )
            Expander(
                title: {
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundColor(.orange)
                        Text("header")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                },
                content: {
                    VStack {
                    }
                    .frame(width: 300, height: 300)
                    .background(.blue.opacity(0.5))
                }
            )
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
