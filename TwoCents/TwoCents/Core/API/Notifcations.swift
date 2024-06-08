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
}

let NOTIFICATION_URL: URL = URL(string: "24.90.210.9:8080/api/notification")!
let NOTIFICATION_TOPIC_URL: URL = URL(string: "24.90.210.9:8080/api/notification-topic")!

func sendSingleNotification(to: String, notification: Notification, completion: @escaping (Bool) -> Void) {
    var request = URLRequest(url: NOTIFICATION_URL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let jsonData = try JSONEncoder().encode(notification)
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
        request.httpBody?.append(try JSONEncoder().encode(to))
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

    do {
        let jsonData = try JSONEncoder().encode(notification)
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
        request.httpBody?.append(try JSONEncoder().encode(to))
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
