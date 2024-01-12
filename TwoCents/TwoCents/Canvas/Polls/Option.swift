//
//  Option.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI

struct Option: Codable, Identifiable, Hashable{
    var id = UUID().uuidString
    var count: Int
    var name: String
}
