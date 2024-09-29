//
//  Utilities.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/11.
//

import Foundation
import SwiftUI

func waitForVariable<T>(_ variable: @escaping () -> T?) -> T {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T?

    DispatchQueue.global().async {
        while result == nil {
            if let value = variable() {
                result = value
                semaphore.signal()
            } else {
                usleep(100_000) // sleep for 100ms to prevent busy waiting
            }
        }
    }

    semaphore.wait()
    return result!
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Color {
    
    static func fromString(name: String) -> Color{
        
        switch name {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
    }
}

//Size multiplier is width/height divided by TILE_SIZE
func roundToTile(number : CGFloat) -> CGFloat {
    let tile = WIDGET_SPACING
    return tile * CGFloat(Int(round(number / (tile))))
}

func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}
