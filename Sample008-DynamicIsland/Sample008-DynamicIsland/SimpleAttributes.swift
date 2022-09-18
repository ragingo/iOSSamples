//
//  SimpleAttributes.swift
//  Sample008-DynamicIsland
//
//  Created by ragingo on 2022/09/18.
//

import Foundation
import ActivityKit

struct SimpleAttributes: ActivityAttributes {
    typealias ContentState = State

    struct State: Codable, Hashable {
        var angle: Double = 0.0
    }
}
