//
//  Collection+Extensions.swift
//  Sample004-AR
//
//  Created by ragingo on 2022/03/21.
//

import Foundation

extension Collection where Element: FloatingPoint, Index == Int {
    var average: Element {
        guard !isEmpty else {
            return .zero
        }
        guard let count = Element(exactly: count) else {
            return .zero
        }
        let sum = reduce(.zero, +)
        return sum / count
    }
}

