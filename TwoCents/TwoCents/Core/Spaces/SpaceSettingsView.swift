//
//  SpaceSettingsView.swift
//  TwoCents
//
//  Created by jonathan on 4/25/24.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct SpaceSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(AppModel.self) var appModel
    @State var viewModel: SpaceSettingsViewModel
    

    private var spaceId: String

    init(spaceId: String) {
        self.spaceId = spaceId
        self.viewModel = SpaceSettingsViewModel(spaceId: spaceId)
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack {
                    Group {
                        //Circle or Profile Pic
                        //
                        //

                        if let urlString = canvasViewModel.space?.profileImageUrl,
                            let url = URL(string: urlString)
                        {

                            //If there is URL for profile pic, show
                            //circle with stroke
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 160, height: 160)

                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database

                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(
                                            tint:
                                                Color(UIColor.systemBackground)

                                        )
                                    )
                                    //                            .scaleEffect(1, anchor: .center)
                                    .frame(width: 160, height: 160)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)

                                    )
                            }

                        } else {

                            //if no profile pic, show circle
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 160, height: 160)

                        }

                    }

                    Text(canvasViewModel.space?.name ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)

                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    if let mySpaceMembers = canvasViewModel.space?.members {

                        Text("\(mySpaceMembers.count) members")
                            .foregroundStyle(.secondary)
                            .font(.headline)

                        //                                                .fontWeight(.regular)

                    }

                    HStack {
                        if viewModel.fetchedInvite {
                            Button {
                                let pasteboard = UIPasteboard.general
                                guard let spaceLink = viewModel.spaceLink else { return }
                                pasteboard.string = spaceLink
                                viewModel.linkMessage = "Copied to clipboard!"
                            } label: {
                                HStack {
                                    Text(viewModel.linkMessage)
                                    Image(systemName: "doc.on.doc")
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .transition(.opacity)
                            
                            if let url = URL(string: viewModel.spaceLink!) {
                                ShareLink(item: url) {
                                    Image(systemName: "square.and.arrow.up")
                                        .frame(width: 30, height: 30)
                                }
                                .transition(.opacity)
                            }
                            NavigationLink {
                                QRCodeView(spaceLink: viewModel.spaceLink!)
                            } label: {
                                Image(systemName: "qrcode")
                                    .frame(width: 30, height: 30)
                            }
                        } else {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text(viewModel.linkMessage)
                                    .foregroundColor(.secondary)
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.fetchedInvite)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thickMaterial)
                .cornerRadius(20)

                Divider()
                    .padding(.vertical)

                VStack {

                    if viewModel.allMembers.isEmpty {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: Color(UIColor.label)))

                    } else {
                        ForEach(viewModel.allMembers) { member in

                            if member.userId != appModel.user?.userId {

                                let targetUserColor: Color =
                                    viewModel.getUserColor(
                                        userColor: member.userColor!)

                                HStack(spacing: 20) {
                                    Group {
                                        //Circle or Profile Pic
                                        if let urlString = member
                                            .profileImageUrl,
                                            let url = URL(string: urlString)
                                        {

                                            //If there is URL for profile pic, show
                                            //circle with stroke
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                                    .frame(
                                                        width: 64, height: 64)

                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database

                                                ProgressView()
                                                    .progressViewStyle(
                                                        CircularProgressViewStyle(
                                                            tint: Color(
                                                                UIColor
                                                                    .systemBackground
                                                            ))
                                                    )
                                                    //                                                .scaleEffect(0.5, anchor: .center)
                                                    .frame(
                                                        width: 64, height: 64
                                                    )
                                                    .background(
                                                        Circle()
                                                            .fill(
                                                                targetUserColor)

                                                    )
                                            }

                                        } else {

                                            //if user has not uploaded profile pic, show circle
                                            Circle()
                                                .fill(targetUserColor)
                                                .frame(width: 64, height: 64)

                                        }

                                    }

                                    //                                    VStack(alignment: .leading){

                                    Text(member.name!)
                                        .font(.headline)

                                    //
                                    //                                        Text(
                                    //                                            "@\(userTile.)")
                                    //                                        .foregroundStyle(.secondary)
                                    //                                        .font(.caption)
                                    //
                                    //                                    }

                                    Spacer()

                                    Button {
                                        Task {

                                            //kick user
                                            //                                            try? await viewModel.removeUser(userId: userTile.userId, spaceId: spaceId)
                                            //                                            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
                                            //                                            try? await viewModel.getMembersInfo()

                                            let generator =
                                                UIImpactFeedbackGenerator(
                                                    style: .medium)
                                            generator.impactOccurred()
                                            //
                                            tickleNotification(
                                                userUID: appModel.user!.userId,
                                                targetUserUID: member.userId,
                                                title: canvasViewModel.space?.name)

                                        }
                                    } label: {
                                        Text("Tickle")
                                            .font(.caption)

                                        //                                    .frame(maxWidth: .infinity)

                                    }
                                    .tint(targetUserColor)
                                    //                                    .tint(.gray)
                                    .buttonStyle(.bordered)
                                    .cornerRadius(10)

                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                .padding(.horizontal)
                                .padding(.vertical, 8)

                                .background(.thickMaterial)
                                .background(targetUserColor)
                                .cornerRadius(10)

                            }
                        }
                    }

                }

                Spacer()

                Divider()
                    .padding(.vertical)

                Button(
                    action: {
                        viewModel.isShowingAddMember = true

                    },
                    label: {
                        Text("Edit Members")
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)

                    }
                )

                .buttonStyle(.bordered)
                .tint(.gray)
                .frame(height: 55)
                .cornerRadius(10)

                Button(
                    action: {
                        viewModel.showingAlert = true
                    },
                    label: {
                        Text(
                            viewModel.allMembers.count <= 2
                                ? "Delete Space" : "Leave Space"
                        )
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)

                    }
                )
                .alert(
                    Text(
                        viewModel.allMembers.count <= 2
                            ? "Delete Space" : "Leave Space"),
                    isPresented: $viewModel.showingAlert,
                    actions: {
                        Button("Cancel", role: .cancel) {}
                        Button(
                            viewModel.allMembers.count <= 2
                                ? "Delete" : "Leave", role: .destructive
                        ) {
                            viewModel.leaveSpaceButton()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    message: {
                        if viewModel.allMembers.count == 2 {
                            Text("Yea... It's getting too romantic in here.")
                        } else if viewModel.allMembers.count == 1 {
                            Text("Yea... It's getting lonely in here.")
                        } else {
                            Text("Do it. Your friends won't mind...")
                        }

                    }
                )
                .disabled(viewModel.allMembers.count == 0)

                .buttonStyle(.bordered)
                .tint(.red)
                .frame(height: 55)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .task {
            try? await viewModel.getMembersInfo(space: canvasViewModel.space)
        }

        .fullScreenCover(
            isPresented: $viewModel.isShowingAddMember,
            onDismiss: {
                Task {
                    try? await viewModel.getMembersInfo(space: canvasViewModel.space)
                }
            },
            content: {
                NavigationView {
                    AddMemberView(spaceId: spaceId)
                }
            })

    }
}

#Preview {
    SpaceSettingsView(spaceId: "F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")

}
