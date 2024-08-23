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
    var canvasWidgets: [CanvasWidget] = []
    var canvas: PKCanvasView
    
    init() {
        self.canvas = PKCanvasView()
    }
    
    /* Eric: Don't delete this
     init(spaceId: String) {
     loadCurrentUser()
     loadCurrentSpace(spaceId: spaceId)
     attachDrawingListener()
     attachWidgetListener()
     }
     */
    
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
    
    func attachDrawingListener() {
        guard let space = space else { return }
        db.collection("spaces").document(space.spaceId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.exists else {
                print("Document doesn't exist")
                return
            }
            
            guard let data = document.data() else {
                print("Empty document")
                return
            }
            
            if let drawingAccess = data["drawing"] as? Data {
                let databaseDrawing = try! PKDrawingReference(data: drawingAccess)
                let newDrawing = databaseDrawing.appending(self.canvas.drawing)
                self.canvas.drawing = newDrawing
            } else {
                print("No database drawing")
            }
        }
        
        
    }
    
    func attachWidgetListener() {
        guard let space = space else { return }
        db.collection("spaces").document(space.spaceId).collection("widgets").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
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
    
    func removeExpiredStrokes() {
        var changed: Bool = false
        let strokes = canvas.drawing.strokes.filter { stroke in
            if (stroke.isExpired()) {
                changed = true
            }
            //include only if not expired
            return !stroke.isExpired()
        }
        if changed {
            
            canvas.drawing = PKDrawing(strokes: strokes)
            guard let space = space else { return }
            canvas.upload(spaceId: space.spaceId)
            
        }
    }
}

enum CanvasSheet: Identifiable  {
    case newWidgetView, chat, poll, newTextView, todo, image, video, calendar
    
    
    var id: Self {
        return self
    }
}
