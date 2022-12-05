//
//  ExpanderHeader.swift
//  Sample012-Expander
//
//  Created by ragingo on 2022/12/05.
//

import SwiftUI

public struct ExpanderHeader<Label: View, ToggleIcon: View>: View {
    private var isExpanded: Binding<Bool>
    private let label: () -> Label
    private let toggleIcon: () -> ToggleIcon

    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder toggleIcon: @escaping () -> ToggleIcon
    ) {
        self.isExpanded = isExpanded
        self.label = label
        self.toggleIcon = toggleIcon
    }

    public var body: some View {
        Button {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack {
                label()
                Spacer()
                toggleIcon()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public extension ExpanderHeader {
    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label,
        toggleIcon: ToggleIcon
    ) where ToggleIcon == Image {
        self.init(isExpanded: isExpanded, label: label, toggleIcon: { toggleIcon })
    }
}

struct ExpanderHeader_Previews: PreviewProvider {
    struct DebugView: View {
        @State var isExpanded = false

        var body: some View {
            ExpanderHeader(
                isExpanded: $isExpanded,
                label: {
                    Text(isExpanded ? "expanded" : "collapsed")
                },
                toggleIcon: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(isExpanded ? .degrees(90) : .zero)
                }
            )
        }
    }

    static var previews: some View {
        DebugView()
    }
}
