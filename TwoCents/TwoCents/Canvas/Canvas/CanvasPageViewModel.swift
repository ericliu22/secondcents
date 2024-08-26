//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import PencilKit



@Observable
final class CanvasPageViewModel {
    
    var user:  DBUser? = nil
    var space:  DBSpace? = nil
    var selectedWidget: CanvasWidget? = nil
    var activeWidget: CanvasWidget?
    var activeSheet: CanvasSheet?
    var replyWidget: CanvasWidget?
    var canvasWidgets: [CanvasWidget] = []
    var spaceId: String
    var isDrawing: Bool = false
    var inSettingsView: Bool = false
    var selectedDetent: PresentationDetent = .height(50)
    var photoLinkedToProfile: Bool = false
    var widgetId: String = UUID().uuidString

    /* Eric: Don't delete this
     init(spaceId: String) {
     loadCurrentUser()
     loadCurrentSpace(spaceId: spaceId)
     attachDrawingListener()
     attachWidgetListener()
     }
     */
    
    //Hard and fast loading
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadCurrentSpace(spaceId: String) async throws {
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
    }
    
    func openMapsApp(location: String) {
        
        let locationAray = location.split(separator: ", ")
        let latitude = String(locationAray[0])
        let longitude = String(locationAray[1])
        
        print(location)
        
        
        let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle error if the Maps app cannot be opened
            print("Cannot open Maps app")
        }
    }
    
    func openLink(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Cannot open link")
        }
    }
    
    func getUserColor(userColor: String) -> Color{
        
        return Color.fromString(name: userColor)
        
    }
    
    func attachWidgetListener() {
        db.collection("spaces").document(spaceId).collection("widgets").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else {
                print("attachWidgetListener closure: weak self no reference")
                return
            }
            guard let query = querySnapshot else {
                print("Error fetching query: \(error!)")
                return
            }
            self.canvasWidgets = []
            for document in query.documents {
                let newWidget = try! document.data(as: CanvasWidget.self)
                self.canvasWidgets.append(newWidget)
            }
        }
    }
    
}

enum CanvasSheet: Identifiable  {
    case newWidgetView, chat, poll, newTextView, todo, image, video, calendar
    
    var id: Self {
        return self
    }
}
