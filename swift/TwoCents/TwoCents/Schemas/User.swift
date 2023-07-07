//
//  User.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/7.
//
import RealmSwift
import Foundation
import UIKit

class User: Object {
    @Persisted(primaryKey: true) var _id: ObjectId?

    @Persisted var displayName: String = ""

    @Persisted var profilePic: List<Int>

    @Persisted var username: String = ""
    
    convenience init(_id: ObjectId? = nil, displayName: String, profilePic: List<Int>?, username: String) {
        self.init()
        let emptyList: List<Int> = List<Int>()
        self._id = _id
        self.displayName = displayName
        self.profilePic = profilePic ?? emptyList
        self.username = username
    }
}

