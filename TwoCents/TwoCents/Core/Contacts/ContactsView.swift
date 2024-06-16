import SwiftUI
import Contacts
import MessageUI

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.contacts, id: \.self) { contact in
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")
                    Text(contact.phoneNumbers.first?.value.stringValue ?? "")
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    viewModel.inviteContact(contact)
                }
            }
            .navigationBarTitle("Contacts")
        }
        .onAppear {
            viewModel.fetchContactsIfNeeded()
        }
    }
}

class ContactsViewModel: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    private let store = CNContactStore()
    @Published var contacts = [CNContact]()
    private var hasFetchedContacts = false
    
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
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                try self.store.enumerateContacts(with: request) { contact, stop in
                    self.contacts.append(contact)
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
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
            UIApplication.shared.windows.first?.rootViewController?.present(messageVC, animated: true, completion: nil)
        } else {
            print("SMS services are not available")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
