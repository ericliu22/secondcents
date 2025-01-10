//
//  DeepLink.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/1.
//
import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

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
func joinSpace(spaceId: String, spaceToken: String) async throws {
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
    
    let joinRequest = JoinSpaceRequest(spaceId: spaceId, spaceToken: spaceToken)
    do {
        let body = try JSONEncoder().encode(joinRequest)
        request.httpBody = body
    } catch {
        throw error
    }
}

fileprivate struct JoinSpaceRequest: Codable {
    let spaceId: String
    let spaceToken: String
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

fileprivate struct FetchSpaceTokenRequest: Codable {
    let spaceId: String
}

func fetchSpaceToken(spaceId: String) async throws -> String {
    guard let apiUrl: URL = URL(string: "https://api.twocentsapp.com/v1/space/fetch-space-token") else {
        throw GenerateInviteLinkError.invalidUrl
    }
    
    guard let firebaseToken = try? await AuthenticationManager.shared.getJwtToken() else {
        throw GenerateInviteLinkError.unauthorizedApp
    }
    
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
    
    let fetchRequest = FetchSpaceTokenRequest(spaceId: spaceId)
    do {
        let body = try JSONEncoder().encode(fetchRequest)
        request.httpBody = body
    } catch {
        throw error
    }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Validate HTTP response
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        let serverError = String(data: data, encoding: .utf8) ?? "Unknown server error"
        throw NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError])
    }
    
    guard let spaceToken = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "Invalid Response Data", code: 0, userInfo: nil)
    }
    
    return spaceToken
}


func generateQRCode(from string: String) -> UIImage? {
    let data = Data(string.utf8)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel") // Medium error correction level
    
    guard let outputImage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale the QR code
    let scaledImage = outputImage.transformed(by: transform)
    
    // Convert to a non-transparent UIImage with proper colors
    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
    
    let size = CGSize(width: scaledImage.extent.size.width, height: scaledImage.extent.size.height)
    UIGraphicsBeginImageContext(size)
    guard let graphicsContext = UIGraphicsGetCurrentContext() else { return nil }
    
    // Fill the background with white
    graphicsContext.setFillColor(UIColor.systemBackground.cgColor)
    graphicsContext.fill(CGRect(origin: .zero, size: size))
    
    // Draw the QR code in black
    graphicsContext.setFillColor(UIColor.systemFill.cgColor)
    graphicsContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return finalImage
}

