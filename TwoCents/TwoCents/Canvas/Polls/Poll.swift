//
//  Poll.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import FirebaseFirestore

struct Option: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var count: Int = 0
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

struct Poll: Codable, Identifiable {
//    static func == (lhs: Poll, rhs: Poll) -> Bool {
//        lhs.id == rhs.id
//    }
    
    var id: UUID
    var name: String
    var options: [Option] = []

    /* Don't know if this is necessary maybe for sorting by lastUpdated -Eric
     
    var lastUpdatedOptionId: String?
    var lastUpdatedOption: Option?{
        guard let lastUpdatedOptionId else {return nil}
        return options.first{ $0.id == lastUpdatedOptionId}
    }
     */
    

    mutating func incrementOption(index: Int) {
        options[index].count += 1
    }
    
    func uploadPoll(spaceId: String) {
        do {
            try db.collection("spaces")
                .document(spaceId)
                .collection("polls")
                .document(id.uuidString)
                .setData(from: self)
        } catch {
            print("Error uploading poll")
        }
    }
    
    func totalVotes() -> Int {
           return options.reduce(0) { $0 + $1.count }
       }
    
    init(canvasWidget: CanvasWidget, options: [Option]) {
        assert(canvasWidget.media == .poll)
        self.id = canvasWidget.id
        self.options = options
        //Theoretically all polls will have names so we manly exclamation mark
        self.name = canvasWidget.widgetName!
    }
}
