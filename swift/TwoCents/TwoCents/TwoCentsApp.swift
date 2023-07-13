//
//  TwoCentsApp.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/7.
//

import SwiftUI
import RealmSwift
import UIKit
typealias SwiftApp = SwiftUI.App
typealias RealmApp = RealmSwift.App
typealias SwiftList = SwiftUI.List
typealias RealmList = RealmSwift.List
typealias RealmUser = RealmSwift.User
typealias UserSchema = User

/*
 Might move a lot of functions here into the startup page
 Realistically don't need to sign in immediately
 */


func openSyncedRealm(user: RealmUser) async throws -> Realm {
        var flexSyncConfig = Globals.app.currentUser!.flexibleSyncConfiguration(initialSubscriptions: { subs in
        subs.append(
            QuerySubscription<UserSchema> {
                try! $0._id == ObjectId(string: user.id)
                })
        }, rerunOnOpen: true)
        
        flexSyncConfig.objectTypes = [User.self]
        print("Got to let realm")
        
        let realm = try await Realm(configuration: flexSyncConfig, downloadBeforeOpen: .never)

        print("finished let realm")
        
        // You must add at least one subscription to read and write from a Flexible Sync realm
        return realm
}

func login(userCredentials: Credentials) async {
    do {
        let user = try await Globals.app.login(credentials: userCredentials)
        print("Successfully logged in user: \(user)")
    } catch {
        print("Error logging in: \(error.localizedDescription)")
    }
}

func registerUser(email: String, password: String, app: RealmApp) async {
    let authInstance: EmailPasswordAuth = EmailPasswordAuth(app: app)
    do {
        try await authInstance.registerUser(email: email, password: password)
        print("Successfully registered user.")
    } catch {
        print("Failed to register: \(error.localizedDescription)")
    }
}

func imageToByteArray(imageData:NSData) -> Array<UInt8> {
  // the number of elements:
  let count = imageData.length / MemoryLayout<Int8>.size

  // create array of appropriate length:
  var bytes = [UInt8](repeating: 0, count: count)

  // copy bytes into array
  imageData.getBytes(&bytes, length:count * MemoryLayout<Int8>.size)

  var byteArray:Array = Array<UInt8>()

  for i in 0 ..< count {
    byteArray.append(bytes[i])
  }

  return byteArray
}

/*
 Arrays and lists are different
 Realm and Swift's lists are different
 UInt8 and Int are different
 */
func arrayToList<T>(array:Array<T>) -> RealmList<Int> {
    var intArray: Array<Int> = []
    for i in array {
        let int8: Int8 = Int8(i as! UInt8)
        let int: Int = Int(int8)
        intArray.append(int)
    }
    let outputList = RealmList<Int>()
    outputList.append(objectsIn: intArray)
    return outputList
}

func imageNameToBytes(imageName: String) -> RealmList<Int> {
    let image = UIImage(named: imageName)
    let data = image!.jpegData(compressionQuality: 1.0)
    let byteArray: Array<UInt8> = imageToByteArray(imageData: data! as NSData)
    let imageBytes = arrayToList(array: byteArray)
    return imageBytes
}



@main
struct Main {
    @MainActor
    static func main() async {
        //These are for test purposes don't actually use
//        let imageBytes = imageNameToBytes(imageName: "jennie kim.jpg")
            let dummyuser = UserSchema(
                _id: try! ObjectId(string: Globals.app.currentUser!.id),
                username: "ericliu",
                displayName: "Eric Liu"
            )
        Globals.app.syncManager.errorHandler = { error,session in
            print("ERROR LOCALIZED DESCRIPTION: \(error.localizedDescription)")
        }
        let email = "ericliu@gmail.com"
        let password = "BLACKP1NK_in_your_area!"
        await registerUser(email: email, password: password, app: Globals.app)
        await login(userCredentials: Credentials.emailPassword(
            email: email,
            password: password))
        do{
            let realm: Realm = try await openSyncedRealm(user:Globals.app.currentUser!)
            let subscriptions = realm.subscriptions
            print(subscriptions.count)
            subscriptions.update {
                   subscriptions.append(
                      QuerySubscription<UserSchema> {
                          try! $0._id == ObjectId(string: Globals.app.currentUser!.id)
                      })
            } onComplete: { error in
                if let error=error {
                    print("Failed to subscribe: \(error.localizedDescription)")
                }
            }
            print("subscriptions.update ran")
            print(realm.syncSession!)
            
            do {
                try! realm.write {
                    realm.add(dummyuser)
                }
                print("REALM CONNECTION STATE: \(String(describing: realm.syncSession?.connectionState))")
                print("Got to write copy")
                print("Wrote copy")
            } catch {
                if error.localizedDescription.contains("existing primary key value") {
                    print("User already exists")
                } else {
                    throw error
                }
            }
            print("realm.write")
        } catch {
            print("Error opening realm: \(error.localizedDescription)")
        }
        MyApp.main()
    }
}

struct MyApp: SwiftApp {
    var body: some Scene {
        WindowGroup {
            StartupPage()
        }
    }
}


/*
 You don't actually need a lot of things here
 The realm app actually has a lot of important functions like
 currentUser and configuration
 */
class Globals {
    static var appConfig: AppConfiguration = AppConfiguration(baseURL: "https://realm.mongodb.com")
    
    static var app: RealmApp = RealmApp(id: "twocents-pmukp", configuration: appConfig)
    
}

