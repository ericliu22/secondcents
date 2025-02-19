//
//  DeleteSpace.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/19.
//


import Foundation

private struct DeleteSpaceRequest: Codable {
    let spaceId: String
}

private enum DeleteSpaceError: Error {
    case invalidUrl
    case unauthorizedApp
    case invalidResponse
    case serverError(message: String, code: Int)
}

extension DeleteSpaceError: LocalizedError {
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

func deleteSpaceRequest(spaceId: String) async throws {

    // Validate and construct the URL
    guard
        let apiUrl = URL(
            string: "https://api.twocentsapp.com/v1/space/delete-space-request")
    else {
        throw DeleteSpaceError.invalidUrl
    }

    // Get the Firebase token
    guard
        let firebaseToken = try? await AuthenticationManager.shared
            .getJwtToken()
    else {
        throw DeleteSpaceError.unauthorizedApp
    }

    // Create the URLRequest
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")

    // Encode the request body
    let deleteSpace = DeleteSpaceRequest(spaceId: spaceId)
    do {
        let body = try JSONEncoder().encode(deleteSpace)
        request.httpBody = body
    } catch {
        throw error
    }

    // Perform the network request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Validate the HTTP response
    guard let httpResponse = response as? HTTPURLResponse else {
        throw DeleteSpaceError.invalidResponse
    }

    // Check if the response indicates success
    guard (200...299).contains(httpResponse.statusCode) else {
        // Read error message from server response
        let serverErrorMessage =
            String(data: data, encoding: .utf8) ?? "Unknown server error"
        throw DeleteSpaceError.serverError(
            message: serverErrorMessage, code: httpResponse.statusCode)
    }

    // Optionally, process the response data if needed
    // For example, parse any returned JSON data

}
