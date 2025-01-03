//
//  DeepLink.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/1.
//
import Foundation

enum JoinSpaceError: Error{
    case invalidUrl
    case unauthorizedApp
}

extension JoinSpaceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL", comment: "")
        case .unauthorizedApp:
            return NSLocalizedString("App user is not authorized", comment: "")
        }
    }
}

/**
 
 Join space API request
 
 REQUIREMENTS:
 - Authorization token of the user to verify request (prevents forcing users into random spaces)
 - Valid link of space (prevents random users into spaces) space JWT token
     - Initial QRCode/Link must have the following structure: https://api.twocentsapp.com/app/space/{spaceId}/{spaceJwtToken}
 (This shit so sus lmao)
 
 Assumes the user currently on the app is the one that is trying to join the space. There is the following workflow that must happen in order:
 1. Fetch space link/QR code from server (This should change every 24 hours)
 2. Show generated QR code
 3. Scan QR Code
 4. User downloads app
 5. Sign up and login
 6. Ask user if they want to join the scanned space (PopupSheet only after the login)
 7. Send API joinSpace request
 8. Verify the request is valid (WIP)
 9. Accept user into the space
 10. (Optional and really hard) auto navigate app to space
*/
func joinSpace(spaceId: String, spaceJwtToken: String) async throws {
    guard let apiUrl: URL = URL(string: "https://api.twocentsapp.com/v1/space/join-space/\(spaceId)") else {
        throw JoinSpaceError.invalidUrl
    }
    
    guard let firebaseToken = try? await AuthenticationManager.shared.getJwtToken() else {
        throw JoinSpaceError.unauthorizedApp
    }
    
    var request = URLRequest(url: apiUrl)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
    request.setValue("\(spaceJwtToken)", forHTTPHeaderField: "SpaceToken")
}

enum GenerateInviteLinkError: Error{
    case invalidUrl
    case unauthorizedApp
}

extension GenerateInviteLinkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL", comment: "")
        case .unauthorizedApp:
            return NSLocalizedString("App user is not authorized", comment: "")
        }
    }
}

func fetchInviteLink(spaceId: String) async throws -> String {
    guard let apiUrl: URL = URL(string: "https://api.twocentsapp.com/v1/space/generate-invite-link/") else {
        throw JoinSpaceError.invalidUrl
    }
    
    guard let firebaseToken = try? await AuthenticationManager.shared.getJwtToken() else {
        throw JoinSpaceError.unauthorizedApp
    }
    
    var request = URLRequest(url: apiUrl)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    let inviteLink = String(data: data, encoding: String.Encoding(rawValue: NSUTF8StringEncoding))!
    return inviteLink
}

func getQRcode(spaceId: String) {
    
}
