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
class PollManager {
    let db = Firestore.firestore()
    
    @MainActor
    func createNewPoll() async{
        //create widget page
    }
}
