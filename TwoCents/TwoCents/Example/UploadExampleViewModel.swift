//
//  UploadExampleViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/15/23.
//

import Foundation
import FirebaseFirestore


final class UploadExampleViewModel: ObservableObject {
    
    //DEFINES THE VARIABLE IN TEXTFIELD
    @Published var inputVariable = ""
    
    
    //THIS GETS THE USER DATA. CAN IGNORE FOR NOW...
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    
    //THIS UPDATES THE USER INFO
    func updateUserInfo() throws {
        let db = Firestore.firestore()
        
        //THE INPUT VARIABLE IN DIRECTLY SENT IN HERE.
        db.collection("Example").document(user!.userId).setData(["UserFavMember": inputVariable],merge: true)
    }
    
    

}
