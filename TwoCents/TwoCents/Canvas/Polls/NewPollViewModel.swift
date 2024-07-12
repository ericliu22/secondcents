//
//  NewPollModel.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class NewPollModel: ObservableObject {
    
    
    
    let db = Firestore.firestore()
    
    var error: String? = nil
    @Published var newPollName: String = ""
    var newOptionName: String = ""
    var newPollOptions: [Option] = []
    
    var isLoading = false
    
    private var spaceId: String
    
//    var isCreateNewPollButtonDisabled: Bool {
//        isLoading ||
//        newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//        newPollOptions.count < 2
//    }
    
//    var isAddOptionsButtonDisabled: Bool {
//        isLoading ||
//        newOptionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//        newPollOptions.count == 10
//    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    
    @MainActor
    func createNewPoll() async {
        
        isLoading = true
        
        defer {isLoading = false}
        
        let uid: String
        let user: DBUser
        do {
            uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            user = try await UserManager.shared.getUser(userId: uid)
        } catch {
            print("Error getting user in NewPollViewModel")
            return
        }

        let newCanvasWidget: CanvasWidget = CanvasWidget(
            x: 0,
            y: 0,
            borderColor: Color.fromString(name: user.userColor!),
            userId: uid,
            media: .poll,
            widgetName: newPollName
            
        )
        
        
        print(newPollOptions)
        let poll=Poll(canvasWidget: newCanvasWidget, options: newPollOptions)
        poll.uploadPoll(spaceId: spaceId)
        self.newPollName = ""
        self.newOptionName = ""
        self.newPollOptions = []
        
        saveWidget(widget: newCanvasWidget)
        //@TODO: Dismiss after submission
        
    }
    
    func saveWidget(widget: CanvasWidget) {
            var uploadWidget: CanvasWidget = widget
        
            uploadWidget.width = TILE_SIZE
            uploadWidget.height = TILE_SIZE
            SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: uploadWidget)
    }
    
    
    
    
    
//    func addOption() {
//        let newOption = Option(name: newOptionName.trimmingCharacters(in: .whitespacesAndNewlines))
//        self.newPollOptions.append(newOption)
//        self.newOptionName = ""
//    }
    
    func addOptions(OptionArray: [String]) {
        for object in OptionArray {
            if object.trimmingCharacters(in: .whitespacesAndNewlines) == "" { continue }
            let newOption = Option(name: object.trimmingCharacters(in: .whitespacesAndNewlines))
            self.newPollOptions.append(newOption)
        }
    }
    
    
}
