//
//  CanvasPageViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import FirebaseFirestore
import FirebaseMessaging
import Foundation
import PencilKit
import SwiftUI

protocol CanvasViewModelDelegate {
    func dismissView()
}

@Observable @MainActor
final class CanvasPageViewModel {

    var space: DBSpace? = nil
    var selectedWidget: CanvasWidget? = nil
    var activeWidget: CanvasWidget?
    var activeSheet: CanvasSheet?
    var replyWidget: CanvasWidget?
    var newWidget: CanvasWidget?
    var canvasWidgets: [CanvasWidget] = []
    var spaceId: String
    var inSubView: Bool = false
    var selectedDetent: PresentationDetent = .height(50)
    var photoLinkedToProfile: Bool = false
    var widgetId: String = UUID().uuidString
    var refreshId = UUID()
    var delegate: CanvasViewModelDelegate?
    var canvasMode: CanvasMode = .normal
    var scrollViewCursor: CGPoint = CGPoint(x: 0, y: 0)
    var canvasPageCursor: CGPoint = CGPoint(x: 0, y: 0)
    var widgetCursor: CGPoint = CGPoint(x: 0, y: 0)
    var unreadWidgets: [String] = []
    var visibleRectInCanvas: CGRect = CGRect(x: 0, y:0, width: 0, height: 0)
    var members: IdentifiedCollection = IdentifiedCollection<DBUser>()
    var zoomScale: CGFloat = 1.0
    
    weak var coordinator: ZoomCoordinatorProtocol?

    /* Eric: Don't delete this
     init(spaceId: String) {
     loadCurrentSpace(spaceId: spaceId)
     attachDrawingListener()
     attachWidgetListener()
     }
     */
    
    enum CanvasMode {
        case normal, placement, drawing, dragging
    }

    enum CanvasSheet: Identifiable {
        case newWidgetView, poll, newTextView, todo, image, video,
            calendar, text, reply

        var id: Self {
            return self
        }
    }

    //Hard and fast loading
    init(spaceId: String) {
        self.spaceId = spaceId
        Messaging.messaging().subscribe(toTopic: spaceId) { error in
            if error != nil {
                print("Failed to subscribe")
            }
        }

    }

    func scrollTo(widgetId: String) {
        guard let widget = canvasWidgets.first(where: { $0.id.uuidString == widgetId }) else {
            return
        }
        coordinator?.scrollToWidget(widget)
    }
    
    func loadCurrentSpace() async throws {
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
    }
    
    func fetchUsers(currentUserId: String) async {
        guard let space = space else {
            return
        }
        
        guard let members = space.members else {
            return
        }
        self.members = IdentifiedCollection<DBUser>()
        for member in members {
            guard let user = try? await UserManager.shared.getUser(userId: member) else {
                continue
            }
            self.members.append(user)
        }
    }
    
    func attachUnreadListener(userId: String) {
        Firestore.firestore().collection("spaces").document(spaceId).collection("unreads").document(userId).addSnapshotListener({ [weak self] documentSnapshot, error in
            guard let self = self else {
                print(
                    "attachUnreadListener closure: weak self no reference")
                return
            }
            guard let document = documentSnapshot else {
                print("Error fetching query: \(error)")
                return
            }
            
            guard let unreads = document.data()?["widgets"] as? [String] else {
                print("attachWidgetListener: Failed to load unreads")
                return
            }
            
            self.unreadWidgets = unreads
        })
    }
    
    func openMapsApp(location: String) {

        let locationAray = location.split(separator: ", ")
        let latitude = String(locationAray[0])
        let longitude = String(locationAray[1])

        print(location)

        let url = URL(
            string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)")!

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
        db.collection("spaces").document(spaceId).collection("widgets")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else {
                    print(
                        "attachWidgetListener closure: weak self no reference")
                    return
                }
                guard let query = querySnapshot else {
                    print("Error fetching query: \(error)")
                    return
                }
                self.canvasWidgets = []
                for document in query.documents {
                    guard let newWidget = try? document.data(as: CanvasWidget.self) else {
                        continue
                    }
                    self.canvasWidgets.append(newWidget)
                }
            }
    }
    
    func confirmPlacement() {
        
        guard let newWidget = newWidget else {
            print("New Widget is nil")
            return
        }
        
        
        var uploadWidget = newWidget
        uploadWidget.x = widgetCursor.x
        uploadWidget.y = widgetCursor.y
        let proposedPoint = CGPoint(x: widgetCursor.x, y: widgetCursor.y)
        if !canPlaceWidget(newWidget, at: proposedPoint) {
            // If collision, you can show an alert, or simply revert, etc.
            print("Cannot place new widget here—collision detected.")
            return
        }

        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: uploadWidget)
        self.newWidget = nil
        canvasMode = .normal
    }

    func deleteWidget(widget: CanvasWidget) {
        if let index = canvasWidgets.firstIndex(of: widget) {
            canvasWidgets.remove(at: index)
            SpaceManager.shared.removeWidget(spaceId: spaceId, widget: widget)

            //delete specific widget items (in their own folders)
            deleteAssociatedWidget(spaceId: spaceId, widgetId: widget.id.uuidString, media: widget.media)

            activeSheet = nil

        }
    }
    
    func deleteAssociatedWidget(spaceId: String, widgetId: String, media: Media) {
        switch media {
            case .poll:
                deletePoll(spaceId: spaceId, pollId: widgetId)
            case .todo:
                deleteTodoList(spaceId: spaceId, todoId: widgetId)
            case .calendar:
                deleteCalendar(
                    spaceId: spaceId, calendarId: widgetId)
            case .chat:
            deleteChat(spaceId: spaceId, chatId: widgetId)
            default:
                break
        }
    }

    func sheetDismiss() {
        replyWidget = nil
        activeWidget = nil

        if photoLinkedToProfile {
            photoLinkedToProfile = false
            widgetId = UUID().uuidString
        } else {
            Task {
                try await StorageManager.shared.deleteTempWidgetPic(
                    spaceId: spaceId, widgetId: widgetId)
            }
        }
    }

    func generateWidgetLink(widget: CanvasWidget) -> String {
        return "https://api.twocentsapp.com/app/widget/\(spaceId)/\(widget.id.uuidString)"
    }
    
    func canPlaceWidget(_ proposedWidget: CanvasWidget, at point: CGPoint) -> Bool {
        // Create a CGRect for the proposed widget at the new point
        print(point)
        let proposedRect = CGRect(
            x: point.x,
            y: point.y,
            width: proposedWidget.width,
            height: proposedWidget.height
        )

        // Compare against all existing widgets
        for existing in canvasWidgets {
            // If it's the same widget, skip
            if existing.id == proposedWidget.id { continue }

            guard
                let existingX = existing.x,
                let existingY = existing.y
            else { continue }

            let existingRect = CGRect(
                x: existingX,
                y: existingY,
                width: existing.width,
                height: existing.height
            )

            // If the bounding boxes overlap, reject
            if proposedRect.intersects(existingRect) {
                return false
            }
        }

        return true
    }
}
