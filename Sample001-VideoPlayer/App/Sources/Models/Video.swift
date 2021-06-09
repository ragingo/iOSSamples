//
//  Video.swift
//  App
//
//  Created by ragingo on 2021/06/09.
//

import Foundation

struct Video: Decodable, Identifiable {
    var id: Int
    var title: String
    var url: String
}
