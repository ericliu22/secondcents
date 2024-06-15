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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    let store = CNContactStore()
    var contacts = [CNContact]()
    var contactsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestContactAccess()
        
        contactsTableView = UITableView(frame: self.view.bounds)
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        self.view.addSubview(contactsTableView)
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
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ContactCell")
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            cell.detailTextLabel?.text = phoneNumber
        }
        return cell
    }
    
    // TableView Delegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        inviteContact(contact)
    }
    
    func createInviteLink() -> String {
        return "https://apps.apple.com/app/6499299457"
    }
    
    func inviteContact(_ contact: CNContact) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Hey, check out this app: \(createInviteLink())"
            
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                messageVC.recipients = [phoneNumber]
            }
            
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        } else {
            print("SMS services are not available")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
