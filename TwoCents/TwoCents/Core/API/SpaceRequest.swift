//
//  AcceptSpaceRequest.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/23.
//

import Foundation

private struct AcceptSpaceRequest: Codable {
    let spaceId: String
}

private enum AcceptSpaceError: Error {
    case invalidUrl
    case unauthorizedApp
    case invalidResponse
    case serverError(message: String, code: Int)
}

extension AcceptSpaceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL.", comment: "")
        case .unauthorizedApp:
            return NSLocalizedString("User is not authorized.", comment: "")
        case .invalidResponse:
            return NSLocalizedString(
                "Invalid response from server.", comment: "")
        case .serverError(let message, _):
            return NSLocalizedString("Server error: \(message)", comment: "")
        }
    }
}

func acceptSpaceRequest(spaceId: String) async throws {

    // Validate and construct the URL
    guard
        let apiUrl = URL(
            string: "https://api.twocentsapp.com/v1/space/accept-space-request")
    else {
        throw AcceptSpaceError.invalidUrl
    }

    // Get the Firebase token
    guard
        let firebaseToken = try? await AuthenticationManager.shared
            .getJwtToken()
    else {
        throw AcceptSpaceError.unauthorizedApp
    }

    // Create the URLRequest
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")

    // Encode the request body
    let acceptSpace = AcceptSpaceRequest(spaceId: spaceId)
    do {
        let body = try JSONEncoder().encode(acceptSpace)
        request.httpBody = body
    } catch {
        throw error
    }

    // Perform the network request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Validate the HTTP response
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AcceptSpaceError.invalidResponse
    }

    // Check if the response indicates success
    guard (200...299).contains(httpResponse.statusCode) else {
        // Read error message from server response
        let serverErrorMessage =
            String(data: data, encoding: .utf8) ?? "Unknown server error"
        throw AcceptSpaceError.serverError(
            message: serverErrorMessage, code: httpResponse.statusCode)
    }

    // Optionally, process the response data if needed
    // For example, parse any returned JSON data

}

private struct SendSpaceRequest: Codable {
    let spaceId: String
    let userId: String
}

private enum SendSpaceError: Error {
    case invalidUrl
    case unauthorizedApp
    case invalidResponse
    case serverError(message: String, code: Int)
}

extension SendSpaceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL.", comment: "")
        case .unauthorizedApp:
            return NSLocalizedString("User is not authorized.", comment: "")
        case .invalidResponse:
            return NSLocalizedString(
                "Invalid response from server.", comment: "")
        case .serverError(let message, _):
            return NSLocalizedString("Server error: \(message)", comment: "")
        }
    }
}

func sendSpaceRequest(spaceId: String, userId: String) async throws {

    // Validate and construct the URL
    guard
        let apiUrl = URL(
            string: "https://api.twocentsapp.com/v1/space/invite-space-request")
    else {
        throw SendSpaceError.invalidUrl
    }

    // Get the Firebase token
    guard
        let firebaseToken = try? await AuthenticationManager.shared
            .getJwtToken()
    else {
        throw SendSpaceError.unauthorizedApp
    }

    // Create the URLRequest
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")

    // Encode the request body
    let sendSpace = SendSpaceRequest(spaceId: spaceId, userId: userId)
    do {
        let body = try JSONEncoder().encode(sendSpace)
        request.httpBody = body
    } catch {
        throw error
    }

    // Perform the network request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Validate the HTTP response
    guard let httpResponse = response as? HTTPURLResponse else {
        throw SendSpaceError.invalidResponse
    }

    // Check if the response indicates success
    guard (200...299).contains(httpResponse.statusCode) else {
        // Read error message from server response
        let serverErrorMessage =
            String(data: data, encoding: .utf8) ?? "Unknown server error"
        throw SendSpaceError.serverError(
            message: serverErrorMessage, code: httpResponse.statusCode)
    }

    // Optionally, process the response data if needed
    // For example, parse any returned JSON data

}
