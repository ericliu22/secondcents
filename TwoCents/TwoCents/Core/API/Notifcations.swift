//
//  Requests.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/5/29.
//

import Foundation

struct Notification: Codable {
    var title: String
    var body: String
    var image: String?
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }

    init(title: String, body: String, image: String) {
        self.title = title
        self.body = body
        self.image = image
    }
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}

let NOTIFICATION_URL: URL = URL(string: "https://api.twocentsapp.com/v1/notification")!
let NOTIFICATION_TOPIC_URL: URL = URL(string: "https://api.twocentsapp.com/v1/notification-topic")!

func sendSingleNotification(to: String, notification: Notification, data: [String:String] = [:], completion: @escaping (Bool) -> Void) {
    var request = URLRequest(url: NOTIFICATION_URL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    guard let notificationDict = notification.toDictionary() else {
        print("Error converting notification to dictionary")
        completion(false)
        return
    }

    let parameters: [String: Any] = ["to": to, "notification": notificationDict, "data": data]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
    } catch let error {
        print("Error encoding parameters: \(error)")
        completion(false)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending request: \(error)")
            completion(false)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response from server")
            completion(false)
            return
        }

        completion(true)
    }

    task.resume()
}

func sendMultipleNotifcation(to: [String], notification: Notification, completion: @escaping (Bool) -> Void) {
    var request = URLRequest(url: NOTIFICATION_URL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    guard let notificationDict = notification.toDictionary() else {
        print("Error converting notification to dictionary")
        completion(false)
        return
    }

    let parameters: [String: Any] = ["to": to, "notification": notificationDict]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
    } catch let error {
        print("Error encoding parameters: \(error)")
        completion(false)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending request: \(error)")
            completion(false)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response from server")
            completion(false)
            return
        }

        completion(true)
    }

    task.resume()
}

func sendNotificationTopic(topic: String, notification: Notification, completion: @escaping (Bool) -> Void) {
    var request = URLRequest(url: NOTIFICATION_TOPIC_URL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let jsonData = try JSONEncoder().encode(notification)
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
        request.httpBody?.append(try JSONEncoder().encode(topic))
    } catch let error {
        print("Error encoding parameters: \(error)")
        completion(false)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending request: \(error)")
            completion(false)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response from server")
            completion(false)
            return
        }

        completion(true)
    }

    task.resume()
}

func getToken(uid: String) async -> String {
    do {
        guard let token = try await db.collection("users").document(uid).getDocument().data()?["token"] as? String else {
            return ""
        }
        return token
    } catch {
        print("Failed to get token")
        return ""
    }
}



func spaceNotification(spaceId: String, userUID: String, notification: Notification) {
    db.collection("spaces").document(spaceId).getDocument { documentSnapshot, error  in
        guard let members = documentSnapshot!.data()!["members"] as? [String] else {
            return
        }
        Task {
            var tokens: [String] = []
            for m in members {
                if (m == userUID) {
                    continue
                }
                
                let token = await getToken(uid: m)
                if (!token.isEmpty) {
                    tokens.append(token)
                }
                
            }
            for token in tokens {
                sendSingleNotification(to: token, notification: notification, data: ["spaceId": spaceId]) { completion in
                    if (completion) {
                        print("Succeded sending")
                    }
                }
            }
        }
        
    }
}

func messageNotification(spaceId: String, userUID: String, message: String) {
    Task {
        let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        let spaceName: String = space.name!
        let name = try await UserManager.shared.getUser(userId: userUID).name
        
        if let spaceImage: String = space.profileImageUrl {
            
            let notification = Notification(title: "\(spaceName)", body: "\(name!): \(message)", image: spaceImage);
            print("IMAGE: \(spaceImage)")
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "\(spaceName)", body: "\(name!): \(message)");
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}

func tickleNotification(userUID: String, targetUserUID: String, count: Int? = nil, title: String? = nil) {
    Task {
        do {
            let user = try await UserManager.shared.getUser(userId: userUID)
            let userName = user.name ?? "User"

            var message: String
            var notificationTitle: String

            if let count = count, count > 0 {
                message = "tickled you \(count) times 🤗"
            } else {
                message = "tickled you 🤗"
            }

            if let title = title {
                notificationTitle = title
                message = "\(userName) \(message)"
            } else {
                notificationTitle = userName
            }

            let notification: Notification
            if let userImage = user.profileImageUrl {
                notification = Notification(title: notificationTitle, body: message, image: userImage)
            } else {
                notification = Notification(title: notificationTitle, body: message)
            }

            let token = await getToken(uid: targetUserUID)
            sendSingleNotification(to: token, notification: notification) { completion in
                if completion {
                    print("Succeeded sending")
                } else {
                    print("Failed to send notification")
                }
            }
        } catch {
            print("Failed to get user or send notification: \(error)")
        }
    }
}


func widgetNotification(spaceId: String, userUID: String, widget: CanvasWidget) {
    Task {
        let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        let spaceName: String = space.name!
        guard let name = try? await UserManager.shared.getUser(userId: userUID).name else {
            print("widgetNotification: Failed to obtain name")
            return
        }
        if let spaceImage: String = space.profileImageUrl {
            let notification = Notification(title: "\(spaceName)", body: "\(name) added a new \(widget.media.name()) widget", image: spaceImage);
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "\(spaceName)", body: "\(name) added a new \(widget.media.name()) widget");
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}

func reactionNotification(spaceId: String, userUID: String, message: String) {
    Task {
        guard let space = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
            print("reactionNotification: Failed to obtain space")
            return
        }
        guard let name = try? await UserManager.shared.getUser(userId: userUID).name else {
            print("reactionNotification: Failed to obtain name")
            return
        }
        
        let spaceName: String = space.name!
        
        if let spaceImage: String = space.profileImageUrl {
            let notification = Notification(title: "\(spaceName)", body: "\(name) \(message) a widget", image: spaceImage);
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "\(spaceName)", body: "\(name) \(message) a widget");
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}

func friendRequestNotification(userUID: String, friendUID: String) async {
    guard let user = try? await UserManager.shared.getUser(userId: userUID) else {
        print("friendRequestNotification: Failed to obtain user")
        return
    }
    let token: String = await getToken(uid: friendUID)
    
    guard let name: String = user.name else {
        print("friendRequestNotification: Failed to obtain name")
        return
    }
    
    if let profileImage = user.profileImageUrl {
        print("IMAGE: \(profileImage)")
        let notification = Notification(title: "\(name) sent you a friend request", body: "\(name) wants to be your friend!", image: profileImage)
        sendSingleNotification(to: token, notification: notification) { completion in
            if (completion) {
                print("Succeeded sending")
            }
        }
    } else {
        let notification = Notification(title: "\(name) sent you a friend request", body: "\(name) wants to be your friend!")
        sendSingleNotification(to: token, notification: notification) { completion in
            if (completion) {
                print("Succeeded sending")
            }
        }
    }
}
