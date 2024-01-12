//
//  Poll.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct Poll: Codable, Identifiable, Hashable {
    var id: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    var name: String
    var totalCount: Int
    
    var option0: Option
    var option1: Option
    var option2: Option?
    var option3: Option?
    var option4: Option?
    var option5: Option?
    var option6: Option?
    var option7: Option?
    var option8: Option?
    var option9: Option?
    
    var options: [Option] {
        var options=[option0, option1]
        if let option2 {options.append(option2)}
        if let option3 {options.append(option3)}
        if let option4 {options.append(option4)}
        if let option5 {options.append(option5)}
        if let option6 {options.append(option6)}
        if let option7 {options.append(option7)}
        if let option8 {options.append(option8)}
        if let option9 {options.append(option9)}
        return options
    }
    
    var lastUpdatedOptionId: String?
    var lastUpdatedOption: Option?{
        guard let lastUpdatedOptionId else {return nil}
        return options.first{ $0.id == lastUpdatedOptionId}
    }
    
    init(id: String, createdAt: Date? = nil, updatedAt: Date? = nil, name: String, totalCount: Int, options: [Option], lastUpdatedOptionId: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.totalCount = totalCount
        
        assert(options.count>=2, "Number of options must be >=2")
        self.option0 = options[0]
        self.option1 = options[1]
        if options.count > 2 {
            self.option2=options[2]
        }
        if options.count > 2 {
            self.option3=options[3]
        }
        if options.count > 2 {
            self.option4=options[4]
        }
        if options.count > 2 {
            self.option5=options[5]
        }
        if options.count > 2 {
            self.option6=options[6]
        }
        if options.count > 2 {
            self.option7=options[7]
        }
        if options.count > 2 {
            self.option8=options[8]
        }
        if options.count > 2 {
            self.option9=options[9]
        }
        self.lastUpdatedOptionId = lastUpdatedOptionId
    }
}
