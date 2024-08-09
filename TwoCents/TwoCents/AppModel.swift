//
//  AppModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/6.
//

import Foundation
import SwiftUI
import Firebase

@Observable
final class AppModel {
    
    var navigationSpaceId: String?
    var shouldNavigateToSpace: Bool = false
    var correctTab: Bool = false
    var inSpace: Bool = false
    var currentSpaceId: String?
    var mutex: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    func addToSpace(userId: String) {
        guard let spaceId = navigationSpaceId else { return }
        Firestore.firestore().collection("spaces").document(spaceId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])
    }
    
}
