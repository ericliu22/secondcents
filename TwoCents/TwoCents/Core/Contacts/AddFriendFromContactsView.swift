import SwiftUI
import Contacts
import MessageUI

struct AddFriendFromContactsView: View {
    @StateObject private var viewModel = AddFriendFromContactsViewModel()
    @State private var searchTerm = ""
    
    var filteredSearch: [CNContact]{
        guard !searchTerm.isEmpty else { return viewModel.contacts}
        return viewModel.contacts.filter{$0.givenName.localizedCaseInsensitiveContains(searchTerm) || $0.familyName.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    
    var body: some View {
        NavigationView {
            List(filteredSearch, id: \.self) { contact in
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")

                    Text(viewModel.user?.id ?? "NONE")
                        .task {
//                            print(contact.phoneNumbers.first?.value.stringValue)
                           await viewModel.getUserWithPhoneNumber(phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "")
//                            await viewModel.getUserWithPhoneNumber(phoneNumber: "6505551234")
                            
                        }
                    Text(contact.phoneNumbers.first?.value.stringValue ?? "")
                        .foregroundColor(.gray)
                  
                }
                .onTapGesture {
                    viewModel.inviteContact(contact)
                }
            }
            .navigationBarTitle("Contacts")
            .searchable(text: $searchTerm, prompt: "Search")
        }
        .onAppear {
            viewModel.fetchContactsIfNeeded()
        }
    }
}


class AddFriendFromContactsViewModel: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    private let store = CNContactStore()
    @Published var contacts = [CNContact]()
    private var hasFetchedContacts = false
    
    
    
    func getUserWithPhoneNumber(phoneNumber: String) async {
        
        self.user = try? await UserManager.shared.getUserWithPhoneNumber(phoneNumber: phoneNumber)
   
    }
    @Published private(set) var user:  DBUser? = nil
    
    
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
