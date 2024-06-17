import SwiftUI
import Contacts
import MessageUI

struct AddFriendFromContactsView: View {
    @StateObject private var viewModel = AddFriendFromContactsViewModel()
    
    @State private var searchTerm = ""
    @Binding var activeSheet: sheetTypes?
    var filteredSearch: [CNContact] {
        guard !searchTerm.isEmpty else { return viewModel.contacts.filter { !$0.givenName.isEmpty && !$0.familyName.isEmpty && !$0.phoneNumbers.isEmpty } }
        return viewModel.contacts.filter {
            ($0.givenName.localizedCaseInsensitiveContains(searchTerm) || $0.familyName.localizedCaseInsensitiveContains(searchTerm)) &&
            (!$0.givenName.isEmpty || !$0.familyName.isEmpty) &&
            !$0.phoneNumbers.isEmpty
        }
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(filteredSearch, id: \.self) { contact in
                        
                        
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                        
                        let user = viewModel.userDictionary[viewModel.getCleanPhoneNumber(phoneNumber: phoneNumber ?? "none")]
                        
                        let targetUserColor = viewModel.getUserColor(userColor: user?.userColor ?? "")
                        
                       
                      
                            
                            HStack(spacing:20){
                                
                                //here
                                
                                Group{
                                    if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 64, height: 64)
                                        
                                        
                                    } else
                                    
                                     if let urlString = user?.profileImageUrl,
                                              let url = URL(string: urlString) {
                                        
                                        
                                        
                                        //If there is URL for profile pic, show
                                        //circle with stroke
                                        AsyncImage(url: url) {image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 64, height: 64)
                                            
                                            
                                            
                                        } placeholder: {
                                            //else show loading after user uploads but sending/downloading from database
                                            
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                            //                                                .scaleEffect(0.5, anchor: .center)
                                                .frame(width: 64, height: 64)
                                                .background(
                                                    Circle()
                                                        .fill(targetUserColor)
                                                        .frame(width: 64, height: 64)
                                                )
                                        }
                                        
                                    } else {
                                        
                                        //if user has not uploaded profile pic, show circle
                                        Circle()
                                        
                                            .strokeBorder(targetUserColor, lineWidth:0)
                                            .background(Circle().fill(targetUserColor))
                                            .frame(width: 64, height: 64)
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                    
                                
                                
                                VStack(alignment: .leading) {
                                
                                
                                Text("\(contact.givenName) \(contact.familyName)")
                                        .font(.headline)
                                
                                if let user {
                                    Text("@\(user.name!)")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                } else {
                                    Text("From contacts")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                }
                                    
                                    
                                    
                                
                                //                            Text(contact.phoneNumbers.first?.value.stringValue ?? "")
                                //                                .foregroundColor(.gray)
                            }
                                
                                Spacer()
                                
                         
                                if let user, let clickedState = viewModel.clickedStates[user.userId] {
                            
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                  

                                        Task{
//                                            viewModel.sendFriendRequest(friendUserId: user.userId!)
                                            if clickedState{
                                              
                                                viewModel.unsendFriendRequest(friendUserId: user.id)
                                               
                                                
                                            } else{
                                                viewModel.sendFriendRequest(friendUserId: user.id)
                                       
                                            }
                                            
                                          
                                        }
                                        
                                    } label: {
                                   
                                            Text(clickedState ? "Undo" : "Add")
                                                .font(.caption)
                                                .frame(width:32)
                                     
                                    }
                                    .tint(targetUserColor)
                                    .buttonStyle(.bordered)
                                    .cornerRadius(10)
                           
                                } else {
                                    
                                    Button {
                                        
                                        Task{
                                            viewModel.inviteContact(contact)
                                        }
                                        
                                    } label: {
                                        
                                        Text("Invite")
                                            .font(.caption)
                                            .frame(width:32)
                                    }
                                    .tint(.gray)
                                    .buttonStyle(.bordered)
                                    .cornerRadius(10)
                                
                                    
                                }
                                
                        }
                    
                        
                        .task {
                            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                                await viewModel.getUserWithPhoneNumber(phoneNumber: phoneNumber)
                            }
                        }
                        
                        .frame(maxWidth: .infinity,  alignment: .leading)
                        
                        
                        
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        .background(.thickMaterial)
                        .background(targetUserColor)
                        .cornerRadius(10)
                        
                        
          
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Contacts 📇")
            
            .onAppear {
                viewModel.fetchContactsIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet  = .customizeProfileView
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color(UIColor.label))
                    }

                }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search")
    }
}


@MainActor
final class AddFriendFromContactsViewModel: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    private let store = CNContactStore()
    @Published var contacts = [CNContact]()
    @Published var userDictionary = [String: DBUser]()
    private var hasFetchedContacts = false
    
    @Published var clickedStates = [String: Bool]()
    
    func sendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
    
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            try? await UserManager.shared.sendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            await friendRequestNotification(userUID: authDataResultUserId, friendUID: friendUserId)
            
            clickedStates[friendUserId] = true
        }
    }
    
    
    
    func unsendFriendRequest(friendUserId: String)  {
        
        guard !friendUserId.isEmpty else { return }
       
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched
            
            let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            guard authDataResultUserId != friendUserId else { return }
            
            
            try? await UserManager.shared.unsendFriendRequest(userId: authDataResultUserId, friendUserId: friendUserId)
            
            clickedStates[friendUserId] = false
        }
    }
    
    
    
    
    
    
    
    func getUserWithPhoneNumber(phoneNumber: String) async {
        do {
            let cleanedPhoneNumber = getCleanPhoneNumber(phoneNumber: phoneNumber)
            if let user = try await UserManager.shared.getUserWithPhoneNumber(phoneNumber: cleanedPhoneNumber){
                userDictionary[cleanedPhoneNumber] = user
                clickedStates[user.userId] = false
            }
        } catch {
            print("Failed to fetch user for phone number \(phoneNumber): \(error)")
        }
    }
    
    
    
    
    
    func getCleanPhoneNumber(phoneNumber: String) -> String {
        return phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
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
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
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
    
    
    func getUserColor(userColor: String) -> Color{

        switch userColor {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
        
        
    }
    
    
}
