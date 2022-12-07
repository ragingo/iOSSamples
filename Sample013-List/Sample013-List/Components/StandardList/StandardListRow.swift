//
//  StandardListRow.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/05.
//

import SwiftUI

struct StandardListRow: View {
    let employee: Employee
    let action: (Employee) -> Void

    var body: some View {
        Button {
            action(employee)
        } label: {
            HStack {
                Image(systemName: "\(employee.id % 50).circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)

                VStack(alignment: .leading) {
                    Text("\(employee.name)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.orange)

                    Text("(id: \(employee.id))")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct StandardListRow_Previews: PreviewProvider {
    static var previews: some View {
        StandardListRow(employee: .init(id: 1, name: "emp 1"), action: { _ in })
    }
}
