//
//  Requests.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/5/29.
//

import Foundation

enum SpaceNotificationType: String, Codable {
    case chat
    case widget
    case emoji
}

struct SpaceNotificationRequest: Codable {
    let type: SpaceNotificationType
    let spaceId: String
    let body: String
    let data: [String: String]?
}

enum SpaceNotificationError: Error {
    case invalidURL
    case noData
    case requestFailed(statusCode: Int)
}

fileprivate func spaceNotification(
    type: SpaceNotificationType,
    spaceId: String,
    body: String,
    data: [String: String]? = nil
) async throws -> String {
    // Replace with your server's URL
    guard
        let url = URL(
            string: "https://api.twocentsapp.com/v1/space/space-notification")
    else {
        throw SpaceNotificationError.invalidURL
    }

    // Configure the URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // Insert JWT token into Authorization header
    let token = try await AuthenticationManager.shared.getJwtToken()
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    // Set content type to JSON
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Build the request body
    let payload = SpaceNotificationRequest(
        type: type, spaceId: spaceId, body: body, data: data)
    let jsonData = try JSONEncoder().encode(payload)
    request.httpBody = jsonData

    // Send request using async/await
    let (responseData, response) = try await URLSession.shared.data(
        for: request)

    
    print("Sent space notification")
    guard let httpResponse = response as? HTTPURLResponse else {
        throw SpaceNotificationError.requestFailed(statusCode: -1)
    }

    // Check for 2xx success status
    guard (200...299).contains(httpResponse.statusCode) else {
        throw SpaceNotificationError.requestFailed(
            statusCode: httpResponse.statusCode)
    }

    // Extract response string, if any
    guard let responseString = String(data: responseData, encoding: .utf8)
    else {
        throw SpaceNotificationError.noData
    }

    return responseString
}

/// Send a "chat" notification.
func chatNotification(
    spaceId: String,
    body: String,
    data: [String: String]? = nil
) async throws -> String {
    let data: [String: String] = [
        "spaceId": spaceId
    ]
    return try await spaceNotification(
        type: .chat,
        spaceId: spaceId,
        body: body,
        data: data
    )
}

/// Send an "emoji" notification.
func reactionNotification(
    spaceId: String,
    body: String,
    widgetId: String
) async throws -> String {
    let data: [String: String] = [
        "spaceId": spaceId,
        "widgetId": widgetId
    ]
    return try await spaceNotification(
        type: .emoji,
        spaceId: spaceId,
        body: body,
        data: data
    )
}

/// Send a "widget" notification.
func widgetNotification(
    spaceId: String,
    name: String,
    widget: CanvasWidget
) async throws -> String {

    let data: [String: String] = [
        "spaceId": spaceId,
        "widgetId": widget.id.uuidString
    ]
    let body: String = "\(name) added a new \(widget.media.name()) widget"
    return try await spaceNotification(
        type: .widget,
        spaceId: spaceId,
        body: body,
        data: data
    )
}
