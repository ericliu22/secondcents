//
//  AppModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/6.
//

import Foundation
import Firebase

@Observable
final class AppModel {
    
    var spaceId: String?
    var shouldNavigateToSpace: Bool = false
    
    func addToSpace(userId: String) {
        guard let spaceId = spaceId else { return }
        Firestore.firestore().collection("spaces").document(spaceId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])
    }
}
