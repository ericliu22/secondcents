//
//  UserNotifications.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/13.
//
import Foundation

//IMPORTANT: userId is always the TARGET of the notification not the person sending it
struct UserNotificationRequest: Codable {
    let type: String
    let userId: String
    let data: [String: String]?
}

enum UserNotificationError: Error {
    case invalidURL
    case noData
    case requestFailed(statusCode: Int)
}

fileprivate func userNotification(
    type: String,
    userId: String,
    data: [String: String]? = nil
) async throws -> String {
    // Replace with your server's URL
    guard
        let url = URL(
            string: "https://api.twocentsapp.com/v1/user/user-notification")
    else {
        throw UserNotificationError.invalidURL
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
    let payload = UserNotificationRequest(type: type, userId: userId, data: data)
    let jsonData = try JSONEncoder().encode(payload)
    request.httpBody = jsonData

    // Send request using async/await
    let (responseData, response) = try await URLSession.shared.data(
        for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw UserNotificationError.requestFailed(statusCode: -1)
    }

    // Check for 2xx success status
    guard (200...299).contains(httpResponse.statusCode) else {
        throw UserNotificationError.requestFailed(
            statusCode: httpResponse.statusCode)
    }

    // Extract response string, if any
    guard let responseString = String(data: responseData, encoding: .utf8)
    else {
        throw UserNotificationError.noData
    }

    return responseString
}

func tickleNotification(userId: String, count: Int) async throws {
    if count <= 1 {
        try await userNotification(type: "tickle", userId: userId)
    } else {
        let data: [String: String] = [
            "count": count.description
        ]
        try await userNotification(type: "multiTickle", userId: userId)
    }
}
