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

let NOTIFICATION_URL: URL = URL(string: "https://guoliangliu.com/api/notification")!
let NOTIFICATION_TOPIC_URL: URL = URL(string: "https://guoliangliu.com/api/notification-topic")!

func sendSingleNotification(to: String, notification: Notification, completion: @escaping (Bool) -> Void) {
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
                sendSingleNotification(to: token, notification: notification) { completion in
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
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: message, image: spaceImage);
            print(notification.title)
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: message);
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}

func widgetNotification(spaceId: String, userUID: String, widget: CanvasWidget) {
    Task {
        let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        let spaceName: String = space.name!
        let name = try await UserManager.shared.getUser(userId: userUID).name
        
        if let spaceImage: String = space.profileImageUrl {
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: "Added a new \(widget.media.name()) widget", image: spaceImage);
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: "Added a new \(widget.media.name()) widget");
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}

func reactionNotification(spaceId: String, userUID: String, message: String) {
    Task {
        let space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        let spaceName: String = space.name!
        let name = try await UserManager.shared.getUser(userId: userUID).name
        
        if let spaceImage: String = space.profileImageUrl {
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: "\(message) a widget", image: spaceImage);
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        } else {
            let notification = Notification(title: "[\(spaceName)] \(name!)", body: "\(message) a widget");
            spaceNotification(spaceId: spaceId, userUID: userUID, notification: notification)
        }
    }
}
