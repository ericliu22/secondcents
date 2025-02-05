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
    
    func toDictionary() -> [String: Any] {
           return [
               "id": id,
               "count": count,
               "name": name
           ]
       }
}

struct Poll: Codable, Identifiable {
//    static func == (lhs: Poll, rhs: Poll) -> Bool {
//        lhs.id == rhs.id
//    }
    
    var id: UUID
    var name: String
    var options: [Option] = []
    var userId: String?
    var votes: [String: Int]?

    /* Don't know if this is necessary maybe for sorting by lastUpdated -Eric
     
    var lastUpdatedOptionId: String?
    var lastUpdatedOption: Option?{
        guard let lastUpdatedOptionId else {return nil}
        return options.first{ $0.id == lastUpdatedOptionId}
    }
     */
    

    mutating func incrementOption(index: Int, userVoted: Int?, userId: String?) {
        if index == userVoted {
            return
        }
        
        //@TODO: There is race condition here
        if userVoted != index && userVoted != nil {
            options[userVoted!].count -= 1
        }
        
        options[index].count += 1

        guard let userId = userId else {
            return
        }
        
        if votes != nil {
            votes![userId] = index
        } else {
            votes = [:]
            votes![userId] = index
        }
    }
    
    func updatePoll(spaceId: String) {
        // Convert options to an array of dictionaries
        let optionsData = options.map { $0.toDictionary() }
        
        let data: [String: Any] = [
            "options": optionsData,
            "votes": votes ?? [:]
        ]
     
        db.collection("spaces")
            .document(spaceId)
            .collection("polls")
            .document(id.uuidString)
            .updateData(data)
      
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
        //Eric here manly is bad always error check
        if let name = canvasWidget.widgetName {
            self.name = name
        } else {
            self.name = ""
        }
        self.userId = canvasWidget.userId
    }
}


func deletePoll(spaceId: String, pollId: String) {
    do {
        try db.collection("spaces")
            .document(spaceId)
            .collection("polls")
            .document(pollId)
            .delete()
    } catch {
        print("Error deleting poll")
    }
}


