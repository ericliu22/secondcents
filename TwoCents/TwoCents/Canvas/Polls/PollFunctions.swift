//
//  PollFunctions.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Observation

@Observable
//fetches poll info for multiple polls and for creating them
class FunctionModel {
    let db = Firestore.firestore()
    var polls = [Poll]()
    
    var error: String? = nil
    var newPollName: String = ""
    var newOptionName: String = ""
//    var newOptionName1: String = ""
//    var newOptionName2: String = ""
//    var newOptionName3: String = ""
//    var newOptionName4: String = ""
//    var newOptionName5: String = ""
//    var newOptionName6: String = ""
//    var newOptionName7: String = ""
//    var newOptionName8: String = ""
//    var newOptionName9: String = ""
    var newPollOptions: [String] = []
    
    var isLoading = false
    var isCreateNewPollButtonDisabled: Bool {
        isLoading ||
        newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        newPollOptions.count < 2
    }
    
    var isAddOptionsButtonDisabled: Bool {
        isLoading ||
        newOptionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        newPollOptions.count == 10
    }
    
    /*
     this function is used in pollSheet to pull up the info for individual polls
     */
    @MainActor
    func listenToLivePolls() {
        db.collection("Chatrooms")
            .document("ChatRoom1")
            .collection("Widgets")
            .document("Polls")
            .collection("Polls")
            .order(by: "updatedAt")
            .addSnapshotListener{ snapshot, error in
                guard let snapshot else {
                    print("Error fetching snapshot: \(error?.localizedDescription ?? "error")")
                    return
                }
                let docs = snapshot.documents
                let polls = docs.compactMap {
                    try? $0.data(as: Poll.self)
                }
                withAnimation {
                    self.polls = polls
                }
            }
    }
    
    @MainActor
    func createNewPoll() async {
        
        isLoading = true
        
        defer {isLoading = false}
        
//        ForEach(newPollOptions) { i in
//            
//        }
        
        let poll=Poll(id: UUID().uuidString, name: newPollName.trimmingCharacters(in: .whitespacesAndNewlines), totalCount: 0, options: newPollOptions.map {Option(count: 0, name: $0)}
        )
        do {
            try db.collection("Chatrooms")
                .document("ChatRoom1")
                .collection("Widgets")
                //.document("Polls\(poll.id)")
                .document("Polls")
                .collection("Polls")
                .document("\(poll.id))")
                .setData(from: poll)
            self.newPollName = ""
            self.newOptionName = ""
            self.newPollOptions = []
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func addOption() {
        self.newPollOptions.append(newOptionName.trimmingCharacters(in: .whitespacesAndNewlines))
        self.newOptionName = ""
    }
}

//listens to updates to each specific poll
//View for single poll
@Observable
class pollViewModel {
    let db = Firestore.firestore()
    let pollId: String
    
    var poll: Poll? = nil
    
    init(pollId: String, poll: Poll? = nil) {
        self.pollId = pollId
        self.poll = poll
    }
    
    //listening for updates to each specific poll
    @MainActor
    func listenToPoll() {
        db.collection("Chatrooms")
            .document("ChatRoom1")
            .collection("Widgets")
            .document("Polls")
            .collection("Polls")
            //.document("polls/\(pollId)")
            .document(pollId)
            .addSnapshotListener { snapshot , error in
                guard let snapshot else {return}
                do {
                    let poll = try snapshot.data(as: Poll.self)
                    withAnimation{
                        self.poll = poll
                    }
                } catch {
                    print("Failed to Fetch Poll")
                }
            }
    }
    
    //function which increments options in polls when people vote
    func incrementOption(_ option: Option) {
        guard let index = poll?.options.firstIndex(where: {$0.id == option.id}) else {return}
        //print(index) works now
        db.collection("Chatrooms")
            .document("ChatRoom1")
            .collection("Widgets")
            .document("Polls")
            .collection("Polls")
            //.document("polls/\(pollId)")
            .document((pollId))
            .updateData([
                "totalCount": FieldValue.increment(Int64(1)),
                /*Desired output: option0, option1, option2, etc
                 "option(\index).count" --> optionOption
                 
                "\(index).count": FieldValue.increment(Int64(1)) --> option
                 */
                "option\(index).count": FieldValue.increment(Int64(1)),
                "lastUpdatedOptionId": option.id,
                "updatedAt": FieldValue.serverTimestamp()
            ]) {error in
                print(error?.localizedDescription ?? "")
            }
    }
}
