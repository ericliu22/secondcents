//
//  AddFriendsFromContactsViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/12/4.
//
import Foundation
import Contacts
import SwiftUI
import MessageUI

@MainActor
final class AddFriendFromContactsViewModel: NSObject, ObservableObject,
    MFMessageComposeViewControllerDelegate
{
    private let store = CNContactStore()
    @Published var contacts = [CNContact]()
    @Published var userDictionary = [String: DBUser]()
    private var hasFetchedContacts = false

    @Published var clickedStates = [String: Bool]()

    func friendRequest(friendUserId: String) {

        guard !friendUserId.isEmpty else {
            print("AddFriendFromContactsView: Failed to get friendUserId")
            return
        }

        Task {
            guard let senderId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
                print("AddFriendFromContactsView: Failed to get userId")
                return
            }
            do {
                try await UserManager.shared.sendFriendRequest(userId: senderId, friendUserId: friendUserId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func unsendFriendRequest(friendUserId: String) {

        guard !friendUserId.isEmpty else { return }

        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched

            let authDataResultUserId = try AuthenticationManager.shared
                .getAuthenticatedUser().uid

            guard authDataResultUserId != friendUserId else { return }

            try? await UserManager.shared.unsendFriendRequest(
                userId: authDataResultUserId, friendUserId: friendUserId)

            clickedStates[friendUserId] = false
        }
    }

    func getUserWithPhoneNumber(phoneNumbers: [String]) async {
        do {
            for phoneNumber in phoneNumbers {
                let cleanedPhoneNumber = getCleanPhoneNumber(
                    phoneNumber: phoneNumber)
                if let user = try await UserManager.shared
                    .getUserWithPhoneNumber(phoneNumber: cleanedPhoneNumber)
                {

                    let currentUserId = try AuthenticationManager.shared
                        .getAuthenticatedUser().uid

                    userDictionary[cleanedPhoneNumber] = user

                    clickedStates[user.userId] = user.incomingFriendRequests?
                        .contains(currentUserId)

                    // Exit the loop once a valid user is found
                    break
                }
            }
        } catch {
            print(
                "Failed to fetch user for phone numbers \(phoneNumbers): \(error)"
            )
        }
    }

    //
    //
    //    func getUserWithPhoneNumber(phoneNumber: String) async {
    //        do {
    //            let cleanedPhoneNumber = getCleanPhoneNumber(phoneNumber: phoneNumber)
    //            if let user = try await UserManager.shared.getUserWithPhoneNumber(phoneNumber: cleanedPhoneNumber){
    //
    //                let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
    //
    //
    //                userDictionary[cleanedPhoneNumber] = user
    //
    //                clickedStates[user.userId] = user.incomingFriendRequests?.contains(currentUserId)
    //            }
    //        } catch {
    //            print("Failed to fetch user for phone number \(phoneNumber): \(error)")
    //        }
    //    }
    //
    //

    func getCleanPhoneNumber(phoneNumber: String) -> String {
        return phoneNumber.components(
            separatedBy: CharacterSet.decimalDigits.inverted
        ).joined()
    }

    func fetchContactsIfNeeded() {
        if !hasFetchedContacts {
            requestContactAccess()
        }
    }

    func requestContactAccess() {
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                self.fetchContacts()
                self.hasFetchedContacts = true
            } else {
                print("Access to contacts was denied")
            }
        }
    }

    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let keys =
                [
                    CNContactGivenNameKey, CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey,
                ] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)

            do {
                try self.store.enumerateContacts(with: request) {
                    contact, stop in
                    self.contacts.append(contact)
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
    }

    func createInviteLink() -> String {
        //        return "https://apps.apple.com/app/6499299457"
        return "https://testflight.apple.com/join/peEvYD11"
    }

    func inviteContact(_ contact: CNContact) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body =
                "\(contact.givenName.uppercased()) ‼️ \n\nget this app rnrnrnrnn! \n\n\(createInviteLink())"

            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                messageVC.recipients = [phoneNumber]
            }

            messageVC.messageComposeDelegate = self
            UIApplication.shared.windows.first?.rootViewController?.present(
                messageVC, animated: true, completion: nil)
        } else {
            print("SMS services are not available")

        }
    }

    func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        controller.dismiss(animated: true, completion: nil)
    }

    func getUserColor(userColor: String) -> Color {

        return Color.fromString(name: userColor)

    }

}
