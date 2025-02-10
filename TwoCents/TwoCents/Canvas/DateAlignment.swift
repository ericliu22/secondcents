//
//  DateAlignment.swift
//  TwoCents
//
//  Created by Joshua Shen on 6/22/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

//let arrayOfDateArrays: [[Date]] = [
//    ["Jun 27, 2024", "Jun 25, 2024", "Jun 26, 2024", "Jun 28, 2024", "Jun 24, 2024"],
//    ["Jun 27, 2024", "Jun 25, 2024", "Jun 26, 2024", "Jun 28, 2024", "Jun 24, 2024"]
//    ["Jun 27, 2024", "Jun 25, 2024", "Jun 26, 2024", "Jun 28, 2024", "Jun 24, 2024"]
//]

func dateAlignment(DatesArray: [[Date]]) -> Date? {
    let flattenedDates = DatesArray.flatMap { $0 }
    var dateCounts: [Date: Int] = [:]
    for date in flattenedDates {
        if let count = dateCounts[date] {
            dateCounts[date] = count + 1
        } else {
            dateCounts[date] = 1
        }
    }
        
        // Step 3: Find the date with the highest count
    let maxCountDate = dateCounts.max { a, b in a.value < b.value }?.key
    
    print(maxCountDate)
    return maxCountDate
}
