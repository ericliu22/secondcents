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

protocol CanvasViewModelDelegate {
    func dismissView()
}

@Observable @MainActor
final class CanvasPageViewModel {
    
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
    var refreshId = UUID()
    var delegate: CanvasViewModelDelegate?
    var zoomScale: CGFloat = 1.0
    
    /* Eric: Don't delete this
     init(spaceId: String) {
     loadCurrentSpace(spaceId: spaceId)
     attachDrawingListener()
     attachWidgetListener()
     }
     */
    
    enum CanvasSheet: Identifiable  {
        case newWidgetView, chat, poll, newTextView, todo, image, video, calendar
        
        var id: Self {
            return self
        }
    }
    
    //Hard and fast loading
    init(spaceId: String) {
        self.spaceId = spaceId
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
    
    func deleteWidget(widget: CanvasWidget) {
        if let index = canvasWidgets.firstIndex(of: widget)  {
            canvasWidgets.remove(at: index)
            SpaceManager.shared.removeWidget(spaceId: spaceId, widget: widget)
            
            //delete specific widget items (in their own folders)
            
            switch widget.media {
                
            case .poll:
                deletePoll(spaceId: spaceId, pollId: widget.id.uuidString)
            case .todo:
                deleteTodoList(spaceId: spaceId, todoId: widget.id.uuidString)
                
            case .calendar:
                deleteCalendar(spaceId: spaceId, calendarId: widget.id.uuidString)
            default:
                break
                
            }
            activeSheet = .chat
            
        }
    }
    
    func sheetDismiss() {
        replyWidget = nil
        activeWidget = nil

        //get chat to show up at all times
        if !inSettingsView && activeSheet == nil{
            print("sheetDismiss: Changing to .chat")
            inSettingsView = false
            activeSheet = .chat
            selectedDetent = .height(50)
        }
        
        
        if photoLinkedToProfile {
            photoLinkedToProfile = false
            widgetId = UUID().uuidString
        } else {
            Task{
                try await StorageManager.shared.deleteTempWidgetPic(spaceId:spaceId, widgetId: widgetId)
            }
        }
    }
    
}
