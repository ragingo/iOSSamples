//
//  Employee.swift
//  Sample013-List
//
//  Created by ragingo on 2022/12/05.
//

import Foundation

struct Employee {
    let id: Int
    let name: String
}

extension Employee: Identifiable {}

extension Employee: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
