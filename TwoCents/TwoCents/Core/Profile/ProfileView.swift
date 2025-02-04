//
//  ProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import SwiftUI

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    @Environment(AppModel.self) var appModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    init(targetUserId: String, targetUserColor: Color? = nil) {
        self.viewModel = ProfileViewModel(targetUserId: targetUserId, targetUserColor: targetUserColor)
    }

    private func startHapticFeedback() {
        feedbackGenerator.prepare()
        var tickleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if viewModel.isPressing {
                feedbackGenerator.impactOccurred()

                tickleCount += 1
                viewModel.tickleString = String(tickleCount)
            } else {
                timer.invalidate()
                viewModel.tickleString = "Tickle"
            }
        }
    }

    private func stopHapticFeedback() {
        // Ensure the feedback generator can be used again if needed
        feedbackGenerator.prepare()
    }

    func profilePic(url: URL) -> some View {

        //If there is URL for profile pic, show
        //circle with stroke
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 128, height: 128)
        } placeholder: {
            //else show loading after user uploads but sending/downloading from database
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(
                        tint:
                            Color(UIColor.systemBackground)

                    )
                )
                .frame(width: 128, height: 128)
                .background(
                    Circle()
                        .fill(viewModel.targetUserColor ?? appModel.loadedColor)
                        .frame(width: 128, height: 128)
                )
        }

    }

    func emptyTargetId() -> some View {
        ZStack {
            Circle()

                .fill(viewModel.targetUserColor ?? appModel.loadedColor)

                .frame(width: 48, height: 48)

            Circle()
                .fill(.thickMaterial)
                .scaleEffect(1.015)
                .frame(width: 48, height: 48)

            Circle()
                .fill(viewModel.targetUserColor ?? appModel.loadedColor)
                .frame(width: 36, height: 36)

            Image(systemName: "plus")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.systemBackground))
        }

        .offset(x: 44, y: 44)
        .onTapGesture {
            //                                        showCreateProfileView = true
            appModel.activeSheet = .customizeProfileView

        }

    }

    @ViewBuilder
    func FriendRequests() -> some View {
        let count: Int = (viewModel.user?.incomingFriendRequests?.count ?? 0) + (viewModel.user?.spaceRequests?.count ?? 0)
        if count == 0 {
            Label(
                "No Requests",
                systemImage: "person.crop.rectangle.stack"
            )

            .font(.headline)
            .fontWeight(.regular)
            //                                                .foregroundColor(Color(UIColor.secondaryLabel))
            .foregroundStyle(.secondary)
        } else {

            Label(
                count == 1
                    ? String(count) + " Request"
                    : String(count) + " Requests",
                systemImage: "person.crop.rectangle.stack"
            )

            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(appModel.loadedColor)

        }

    }

    var body: some View {

        VStack {
            //for padding
            VStack {
                HStack {
                    VStack {
                        ZStack {

                            Group {
                                if let urlString = viewModel.user?
                                    .profileImageUrl,
                                    let url = URL(string: urlString)
                                {
                                    profilePic(url: url)
                                } else {
                                    //if user has not uploaded profile pic, show circle
                                    Circle()
                                        .fill(
                                            viewModel.targetUserColor
                                                ?? appModel.loadedColor
                                        )
                                        .frame(width: 128, height: 128)
                                }

                                if viewModel.targetUserId.isEmpty {
                                    emptyTargetId()
                                }
                            }
                        }

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        if let user = viewModel.user {

                            if let name = user.name {
                                Text("\(name)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        viewModel.targetUserColor
                                            ?? appModel.loadedColor
                                    )
                                    //protects text overflow
                                    .padding([.leading, .trailing], nil)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }

                            //CAN ADD NICKNAME IN FUTURE!!!
                            //                            if let username = user.username, username != ""  {
                            //                                Text("@\(username)" )
                            //                                //                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            //                                    .foregroundStyle(.secondary)
                            //
                            //                                    .font(.headline)
                            //
                            //                                    .fontWeight(.regular)
                            //
                            //                                //protects text overflow
                            //                                    .padding([.leading, .trailing],nil)
                            //                                //                                .minimumScaleFactor(0.5)
                            //                                    .lineLimit(1)
                            //
                            //
                            //
                            //                            }
                        }

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(2, contentMode: .fit)
                .background(.thickMaterial)
                .background(viewModel.targetUserColor ?? appModel.loadedColor)
                .cornerRadius(20)

                LazyVGrid(columns: columns, spacing: nil) {

                    VStack {
                        if let user = viewModel.user,
                            let dateCreated = user.dateCreated
                        {
                            // Calculate user's age in days
                            let calendar = Calendar.current
                            let currentDate = Date()

                            if let userAge = calendar.dateComponents(
                                [.day], from: dateCreated, to: currentDate
                            ).day {
                                Text(
                                    userAge == 1
                                        ? "\(userAge) day" : "\(userAge) days"
                                )
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)

                                Text("of adventure")
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)

                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thickMaterial)
                    .cornerRadius(20)
                    VStack {
                        NavigationLink {
                            //                            FriendsView(showSignInView: $showSignInView, appModel.loadedColor: $appModel.loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: viewModel.user?.userId ?? "")
                            FriendsView(
                                targetUserId: viewModel.user?.userId ?? "")
                        } label: {

                            VStack {
                                if let user = viewModel.user {
                                    if let friends = user.friends {
                                        Text(String(friends.count))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(
                                                viewModel.targetUserColor
                                                    ?? appModel.loadedColor)
                                        Text(
                                            friends.count == 1
                                                ? "Friend" : "Friends"
                                        )
                                        .font(.headline)
                                        .fontWeight(.regular)
                                    }
                                }
                            }
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)

                        }

                        if viewModel.targetUserId.isEmpty {

                            NavigationLink {

                                if let userId = appModel.user?.userId {
                                    RequestsView(userId: userId)
                                }
                            } label: {

                                VStack {
                                    FriendRequests()
                                }
                                .foregroundColor(Color(UIColor.label))
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity
                                )
                                .background(.thinMaterial)
                                .cornerRadius(20)

                            }

                        } else {
                            if viewModel.isFriend != nil,
                                viewModel.requestSent != nil,
                                viewModel.requestedMe != nil
                            {
                                Button {

                                    if viewModel.isFriend! {
                                        viewModel.removeFriend(
                                            friendUserId: viewModel.targetUserId
                                        )
                                    } else {
                                        if viewModel.requestedMe! {
                                            viewModel.acceptFriendRequest(
                                                friendUserId: viewModel
                                                    .targetUserId)

                                        } else {
                                            viewModel.requestSent!
                                                ? viewModel.unsendFriendRequest(
                                                    friendUserId: viewModel
                                                        .targetUserId)
                                                : viewModel.sendFriendRequest(
                                                    friendUserId: viewModel
                                                        .targetUserId)
                                        }
                                    }

                                } label: {

                                    HStack {

                                        if viewModel.isFriend! {

                                            Label(
                                                "Friended",
                                                systemImage:
                                                    "person.crop.circle.badge.checkmark"
                                            )

                                        } else {
                                            if viewModel.requestedMe! {

                                                Label(
                                                    "Accept Request",
                                                    systemImage:
                                                        "person.badge.plus")

                                            } else {

                                                viewModel.requestSent!
                                                    ? Label(
                                                        "Request Sent",
                                                        systemImage:
                                                            "paperplane")

                                                    : Label(
                                                        "Add Friend",
                                                        systemImage:
                                                            "person.badge.plus")

                                            }
                                        }

                                    }

                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .tint(
                                        viewModel.targetUserColor
                                            ?? appModel.loadedColor
                                    )
                                    .animation(nil, value: viewModel.isFriend!)
                                    .animation(
                                        nil, value: viewModel.requestSent!
                                    )

                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity
                                    )
                                    .background(.thinMaterial)

                                    .cornerRadius(20)

                                }

                            }

                        }

                    }
                    .aspectRatio(1, contentMode: .fit)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thinMaterial)
                            .aspectRatio(1, contentMode: .fit)
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        if let startTime = viewModel
                                            .pressStartTime
                                        {
                                            let duration = Date()
                                                .timeIntervalSince(startTime)
                                            let tickleCount = Int(duration * 10)

                                            if !viewModel.isPressing
                                                && tickleCount <= 1
                                            {

                                                feedbackGenerator.impactOccurred()

                                                let currentUserId =
                                                    try! AuthenticationManager
                                                    .shared
                                                    .getAuthenticatedUser().uid
                                                //
                                                //
                                                Task {
                                                    try await tickleNotification(
                                                        userId: viewModel
                                                            .targetUserId,
                                                        count: tickleCount)
                                                }
                                                AnalyticsManager.shared.tickle(
                                                    count: tickleCount)
                                            }

                                        }

                                    }
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)  // Detects any drag or press
                                    .onChanged { _ in
                                        if !viewModel.isPressing {
                                            viewModel.isPressing = true
                                            viewModel.pressStartTime = Date()
                                            startHapticFeedback()
                                        }
                                    }
                                    .onEnded { _ in
                                        if viewModel.isPressing {
                                            viewModel.isPressing = false
                                            stopHapticFeedback()

                                            if let startTime = viewModel
                                                .pressStartTime
                                            {
                                                let duration = Date()
                                                    .timeIntervalSince(
                                                        startTime)
                                                let tickleCount = Int(
                                                    duration * 10)

                                                if tickleCount > 1 {
                                                    let currentUserId =
                                                        try!
                                                        AuthenticationManager
                                                        .shared
                                                        .getAuthenticatedUser()
                                                        .uid
                                                    Task {
                                                        try await
                                                            tickleNotification(
                                                                userId:
                                                                    viewModel
                                                                    .targetUserId,
                                                                count:
                                                                    tickleCount)
                                                    }
                                                    AnalyticsManager.shared
                                                        .tickle(
                                                            count: tickleCount)
                                                }
                                            }
                                        }

                                    }
                            )

                        Text(viewModel.tickleString)
                            .font(
                                viewModel.tickleString == "Tickle"
                                    ? .title2 : .largeTitle
                            )
                            .fontWeight(.bold)
                            .fontDesign(
                                viewModel.tickleString == "Tickle"
                                    ? .default : .monospaced
                            )
                            .foregroundStyle(.secondary)
                            .frame(height: 50)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thinMaterial)
                            .aspectRatio(1, contentMode: .fit)

                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                    }

                }

            }
            .padding()

            Spacer()

        }

        .task {
            if viewModel.targetUserId.isEmpty {
                if let user = appModel.user {
                    viewModel.user = user
                    viewModel.attachUserListener(userId: user.userId)
                }
            } else {
                try? await viewModel.loadTargetUser(
           targetUserId: viewModel.targetUserId)
                guard let currentUser = appModel.user else {
                    print("No authenticated user")
                    return
                }
                viewModel.checkFriendshipStatus(currentUserId: currentUser.userId)
                viewModel.checkRequestStatus(currentUserId: currentUser.userId)
                viewModel.checkRequestedMe(currentUserId: currentUser.userId)

            }
        }

        .onDisappear(perform: {
            if viewModel.isPressing {
                viewModel.isPressing = false
                stopHapticFeedback()

                if let startTime = viewModel.pressStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    let tickleCount = Int(duration * 10)

                    if tickleCount > 1 {
                        let currentUserId = try! AuthenticationManager.shared
                            .getAuthenticatedUser().uid

                        Task {
                            try await tickleNotification(
                                userId: viewModel.targetUserId,
                                count: tickleCount)
                        }
                        AnalyticsManager.shared.tickle(count: tickleCount)
                    }
                }
            }

        })

        .navigationTitle("Profile 🤠")
        .toolbar {
            if viewModel.targetUserId.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {

                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

/*
 struct ProfileView_Previews: PreviewProvider {
 static var previews: some View {
 NavigationStack {
 //            ProfileView(showSignInView: .constant(false),appModel.loadedColor: .constant(.red),showCreateProfileView: .constant(false), targetUserId: "")
 ProfileView(appModel.activeSheet: .constant(nil), appModel.loadedColor: .constant(.red), targetUserId: "")
 }
 }
 }
 */
