import Contacts
import MessageUI
import SwiftUI

struct AddFriendFromContactsView: View {
    @StateObject private var viewModel = AddFriendFromContactsViewModel()

    @State private var searchTerm = ""
    @Environment(AppModel.self) var appModel
    var filteredSearch: [CNContact] {
        guard !searchTerm.isEmpty else {
            return viewModel.contacts
                .filter { !$0.phoneNumbers.isEmpty }
                .sorted { $0.givenName < $1.givenName }
        }

        return viewModel.contacts.filter {
            ($0.givenName.localizedCaseInsensitiveContains(searchTerm)
                || $0.familyName.localizedCaseInsensitiveContains(searchTerm)
                || $0.phoneNumbers.contains(where: {
                    $0.value.stringValue.contains(searchTerm)
                })) && !$0.phoneNumbers.isEmpty

        }
        .sorted { $0.givenName < $1.givenName }
    }

    var body: some View {
        //        NavigationView {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(filteredSearch, id: \.self) { contact in

                    //
                    //                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                    //
                    //                        let user = viewModel.userDictionary[viewModel.getCleanPhoneNumber(phoneNumber: phoneNumber ?? "none")]
                    //
                    //                        let targetUserColor = viewModel.getUserColor(userColor: user?.userColor ?? "")
                    //
                    //
                    let phoneNumbers = contact.phoneNumbers.map {
                        $0.value.stringValue
                    }

                    let user =
                        phoneNumbers
                        .compactMap {
                            viewModel.userDictionary[
                                viewModel.getCleanPhoneNumber(phoneNumber: $0)]
                        }
                        .first

                    let targetUserColor = viewModel.getUserColor(
                        userColor: user?.userColor ?? "")

                    HStack(spacing: 20) {

                        //here

                        Group {
                            if let imageData = contact.thumbnailImageData,
                                let image = UIImage(data: imageData)
                            {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 64, height: 64)

                            } else if let urlString = user?.profileImageUrl,
                                let url = URL(string: urlString)
                            {

                                //If there is URL for profile pic, show
                                //circle with stroke
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 64, height: 64)

                                } placeholder: {
                                    //else show loading after user uploads but sending/downloading from database

                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: Color(
                                                    UIColor.systemBackground))
                                        )
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

                                    .fill(targetUserColor)
                                    .frame(width: 64, height: 64)

                            }

                        }

                        VStack(alignment: .leading) {

                            if contact.givenName.isEmpty
                                && contact.familyName.isEmpty
                            {
                                Text("Nameless Contact")
                                    .font(.headline)
                            } else {
                                Text(
                                    "\(contact.givenName) \(contact.familyName)"
                                )
                                .font(.headline)
                            }

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

                        if let user,
                            let clickedState = viewModel.clickedStates[
                                user.userId]
                        {

                            Button {
                                let generator = UIImpactFeedbackGenerator(
                                    style: .medium)
                                generator.impactOccurred()

                                print(clickedState)

                                Task {
                                    //                                            viewModel.sendFriendRequest(friendUserId: user.userId!)
                                    if clickedState {

                                        viewModel.unsendFriendRequest(
                                            friendUserId: user.id)

                                    } else {
                                        viewModel.friendRequest(
                                            friendUserId: user.id)

                                    }

                                }

                            } label: {

                                Text(clickedState ? "Undo" : "Add")
                                    .font(.caption)
                                    .frame(width: 32)

                            }
                            .tint(targetUserColor)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)

                        } else {

                            Button {

                                let generator = UIImpactFeedbackGenerator(
                                    style: .medium)
                                generator.impactOccurred()

                                Task {
                                    viewModel.inviteContact(contact)
                                }

                            } label: {

                                Text("Invite")
                                    .font(.caption)
                                    .frame(width: 32)
                            }
                            //                                    .tint(.gray)
                            .tint(targetUserColor)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)

                        }

                    }

                    .task {
                        await viewModel.getUserWithPhoneNumber(
                            phoneNumbers: phoneNumbers)
                    }

                    .frame(maxWidth: .infinity, alignment: .leading)

                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    .background(.thickMaterial)
                    .background(targetUserColor)
                    .cornerRadius(10)

                    .animation(.easeIn, value: targetUserColor != .gray)

                }

            }
            .padding(.horizontal)
        }
        .navigationBarTitle("Contacts 📇")

        .onAppear {
            viewModel.fetchContactsIfNeeded()
        }
        .toolbar {

            if appModel.activeSheet != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appModel.activeSheet = .customizeProfileView
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color(UIColor.label))
                    }

                }
            }
        }
        //        }
        .searchable(text: $searchTerm, prompt: "Search")

        .scrollDismissesKeyboard(.interactively)
    }
}

