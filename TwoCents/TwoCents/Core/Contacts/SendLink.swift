//
//  SendLink.swift
//  TwoCents
//
//  Created by Joshua Shen on 6/12/24.
//
import Foundation
import SwiftUI
import UIKit
import Contacts
import MessageUI
import FirebaseDynamicLinks

struct ContactsView: View {
    var body: some View {
        ContactsViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContactsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed for this view controller.
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UISearchBarDelegate {
    
    let store = CNContactStore()
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var contactsTableView: UITableView!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestContactAccess()
        
        contactsTableView = UITableView(frame: self.view.bounds)
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        self.view.addSubview(contactsTableView)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        contactsTableView.tableHeaderView = searchBar
    }
    
    func requestContactAccess() {
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                self.fetchContacts()
            } else {
                print("Access to contacts was denied")
            }
        }
    }
    
    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            
            do {
                try self.store.enumerateContacts(with: request) { contact, stop in
                    self.contacts.append(contact)
                }
                self.contacts.sort { ($0.givenName + $0.familyName) < ($1.givenName + $1.familyName) }
                self.filteredContacts = self.contacts
                DispatchQueue.main.async {
                    self.contactsTableView.reloadData()
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ContactCell")
        let contact = filteredContacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            cell.detailTextLabel?.text = phoneNumber
        }
        return cell
    }
    
    // TableView Delegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = filteredContacts[indexPath.row]
        inviteContact(contact)
    }
    
    func createInviteLink(withToken token: String, completion: @escaping (URL?) -> Void) {
        // Use the non-dynamic invite link as the base URL
        guard let link = URL(string: "https://apps.apple.com/app/6499299457?token=\(token)") else {
            completion(nil)
            return
        }

        // Replace with your dynamic links domain from Firebase Console
        let dynamicLinksDomainURIPrefix = "https://yourapp.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)

        // Replace with your app's bundle ID
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)

        // Shorten the link and return it in the completion handler
        linkBuilder?.shorten(completion: { url, warnings, error in
            if let error = error {
                print("Error creating short link: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Print the generated invite link for debugging purposes
            if let inviteLink = url {
                print("Generated invite link: \(inviteLink.absoluteString)")
            }
            
            completion(url)
        })
    }

    func inviteContact(_ contact: CNContact) {
        if MFMessageComposeViewController.canSendText() {
            do {
                let uniqueToken = try AuthenticationManager.shared.getAuthenticatedUser().uid  // Generate a unique token for the invite

                createInviteLink(withToken: uniqueToken) { inviteLink in
                    guard let inviteLink = inviteLink else {
                        print("Failed to create invite link")
                        return
                    }

                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        let messageVC = MFMessageComposeViewController()
                        messageVC.body = "Hey, check out this app: \(inviteLink.absoluteString)"
                        messageVC.recipients = [phoneNumber]
                        messageVC.messageComposeDelegate = self
                        self.present(messageVC, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Failed to get authenticated user: \(error.localizedDescription)")
            }
        } else {
            print("SMS services are not available")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // SearchBar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { contact in
                let name = "\(contact.givenName) \(contact.familyName)"
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    return name.lowercased().contains(searchText.lowercased()) || phoneNumber.contains(searchText)
                }
                return name.lowercased().contains(searchText.lowercased())
            }
        }
        contactsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredContacts = contacts
        contactsTableView.reloadData()
    }
}
