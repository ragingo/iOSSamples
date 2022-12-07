//
//  TableViewButtonCell.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/07.
//

import SwiftUI

struct TableViewButtonCell<Label: View>: View {
    private let label: () -> Label
    private let action: () -> Void

    init(@ViewBuilder label: @escaping () -> Label, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label()
        }
    }
}

struct TableViewButtonCell_Previews: PreviewProvider {
    static var previews: some View {
        TableViewButtonCell(
            label: {
                Image(systemName: "car")
                    .resizable()
                    .frame(width: 50)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.red)
            }) {
            }
    }
}
