//
//  FriendRequest.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/12/3.
//

import Foundation

struct FriendRequest: Codable {
    let senderId: String
    let receiverId: String
}

enum FriendRequestError: Error {
    case invalidUrl
    case unauthorizedApp
    case invalidResponse
}

extension FriendRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("URL is not correct", comment: "")
        case .unauthorizedApp:
            return NSLocalizedString("App user is not authorized", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Request received invalid response", comment: "")
        }
    }
}

@discardableResult
func sendFriendRequest(senderId: String, receiverId: String) async throws -> String {
    guard let url = URL(string: "https://api.twocentsapp.com/v1/user/send-friend-request") else {
        throw FriendRequestError.invalidUrl
    }
    try await sendRequest(senderId: senderId, receiverId: receiverId, url: url)
    
    return "Send Friend request successful"
}

@discardableResult
func unsendFriendRequest(senderId: String, receiverId: String) async throws -> String {
    guard let url = URL(string: "https://api.twocentsapp.com/v1/user/unsend-friend-request") else {
        throw FriendRequestError.invalidUrl
    }
    try await sendRequest(senderId: senderId, receiverId: receiverId, url: url)
    
    return "Unsend Friend request success"
}

@discardableResult
func removefriendRequest(senderId: String, receiverId: String) async throws -> String {
    guard let url = URL(string: "https://api.twocentsapp.com/v1/user/remove-friend-request") else {
        throw FriendRequestError.invalidUrl
    }
    try await sendRequest(senderId: senderId, receiverId: receiverId, url: url)
    
    return "Remove Friend request success"
}

@discardableResult
func acceptFriendRequest(senderId: String, receiverId: String) async throws -> String {
    guard let url = URL(string: "https://api.twocentsapp.com/v1/user/accept-friend-request") else {
        throw FriendRequestError.invalidUrl
    }
    try await sendRequest(senderId: senderId, receiverId: receiverId, url: url)
    
    return "Accept Friend request success"
}

@discardableResult
func declineFriendRequest(senderId: String, receiverId: String) async throws -> String {
    guard let url = URL(string: "https://api.twocentsapp.com/v1/user/decline-friend-request") else {
        throw FriendRequestError.invalidUrl
    }
    try await sendRequest(senderId: senderId, receiverId: receiverId, url: url)
    
    return "Decline Friend request success"
}

fileprivate func sendRequest(senderId: String, receiverId: String, url: URL) async throws {
    print("SENDERID: \(senderId)")
    print("RECEIVERID: \(receiverId)")
    guard let firebaseToken = try? await AuthenticationManager.shared.getJwtToken() else {
        throw FriendRequestError.unauthorizedApp
    }
    print(firebaseToken)
    
    // Prepare the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
    
    // Encode the body
    let friendRequest = FriendRequest(senderId: senderId, receiverId: receiverId)
    do {
        let body = try JSONEncoder().encode(friendRequest)
        request.httpBody = body
    } catch {
        throw error
    }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw FriendRequestError.invalidResponse
    }
}
