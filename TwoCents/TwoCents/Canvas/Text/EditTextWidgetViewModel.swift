//
//  EditTextWidgetViewModel.swift
//  TwoCents
//
//  Created by Joshua Shen on 10/27/24.
//
import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
final class EditTextWidgetViewModel: ObservableObject {
    @Published private(set) var WidgetMessage: CanvasWidget? = nil
    func loadWidget(spaceId: String, widgetId: String) async throws {
        self.WidgetMessage = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId)
    }
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
    }
    
    @Published private(set) var WidgetId: UUID? = nil
    func loadWidgetId(spaceId: String, widgetId: String) async throws {
        self.WidgetId = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId).id
    }
    
    @Published var WidgetTextString: String? = nil
    func loadWidgetTextString(spaceId: String, widgetId: String) async throws {
        self.WidgetTextString = try await SpaceManager.shared.getWidget(spaceId: spaceId, widgetId: widgetId).textString
    }
    
    //I think just update field is fine?
    func uploadEditedText(spaceId: String, text: String, widgetId: UUID) {
        Firestore.firestore().collection("spaces")
            .document(spaceId)
            .collection("widgets")
            .document(widgetId.uuidString)
            .updateData(["textString": text])
    }
}
