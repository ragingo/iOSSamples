//
//  TableViewTextCell.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/07.
//

import SwiftUI

struct TableViewTextCell: View {
    let text: String

    var body: some View {
        Text(text)
    }
}

struct TableViewTextCell_Previews: PreviewProvider {
    static var previews: some View {
        TableViewTextCell(text: "hello")
    }
}
