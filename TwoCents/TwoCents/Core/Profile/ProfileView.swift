//
//  ProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State var targetUserColor: Color?
    @Environment(AppModel.self) var appModel
    //    @Binding var showSignInView: Bool
    @State var target: Color?
    //    @Binding var showCreateProfileView: Bool
    
    @State var targetUserId: String
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    @State private var isPressing = false
    @State private var pressStartTime: Date?
    @State private var tickleString: String = "Tickle"
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    
    private func startHapticFeedback() {
        feedbackGenerator.prepare()
        var tickleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if isPressing {
                feedbackGenerator.impactOccurred()
                
                
                tickleCount += 1
                tickleString = String(tickleCount)
            } else {
                timer.invalidate()
                tickleString = "Tickle"
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
        AsyncImage(url: url) {image in
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 128, height: 128)
        } placeholder: {
            //else show loading after user uploads but sending/downloading from database
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint:
                                                Color(UIColor.systemBackground)
                                              
                                             )
                )
            //                            .scaleEffect(1, anchor: .center)
                .frame(width: 128, height: 128)
                .background(
                    Circle()
                        .fill(targetUserColor ?? appModel.loadedColor)
                        .frame(width: 128, height: 128)
                )
        }
        
        
    }
    
    func emptyTargetId() -> some View {
        ZStack{
            Circle()
            
                .fill(targetUserColor ?? appModel.loadedColor)
            
                .frame(width: 48, height: 48)
            
            Circle()
                .fill(.thickMaterial)
                .scaleEffect(1.015)
                .frame(width: 48, height: 48)
            
            Circle()
                .fill(targetUserColor ?? appModel.loadedColor)
                .frame(width: 36, height: 36)
            
            
            Image(systemName: "plus")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        
        .offset(x:44, y:44)
        .onTapGesture{
            //                                        showCreateProfileView = true
            appModel.activeSheet = .customizeProfileView
            
        }
        
    }
    
    @ViewBuilder
    func friendRequests(incomingFriendRequests: Array<String>) -> some View {
        if incomingFriendRequests.count == 0 {
            Label("No Requests",
                  systemImage: "person.crop.rectangle.stack")
            
            .font(.headline)
            .fontWeight(.regular)
            //                                                .foregroundColor(Color(UIColor.secondaryLabel))
            .foregroundStyle(.secondary)
        } else {
            
            Label(incomingFriendRequests.count == 1
                  ? String(incomingFriendRequests.count)  +   " Request"
                  : String(incomingFriendRequests.count)  +    " Requests",
                  systemImage: "person.crop.rectangle.stack")
            
            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(appModel.loadedColor)
            
        }
        
    }
    
    var body: some View {
        
        VStack {
            //for padding
            VStack{
                HStack{
                    VStack {
                        ZStack{
                            
                            Group{
                                if let urlString = viewModel.user?.profileImageUrl,
                                   let url = URL(string: urlString) {
                                    profilePic(url: url)
                                } else {
                                    //if user has not uploaded profile pic, show circle
                                    Circle()
                                        .fill(targetUserColor ?? appModel.loadedColor)
                                        .frame(width: 128, height: 128)
                                }
                                
                                if (targetUserId.isEmpty) {
                                    emptyTargetId()
                                }
                            }
                        }
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    //                .aspectRatio(1, contentMode: .fit)
                    //                    .background(.thinMaterial)
                    //                    .cornerRadius(20)
                    
                    
                    
                    VStack{
                        if let user = viewModel.user {
                            
                            if let name = user.name  {
                                Text("\(name)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(targetUserColor ?? appModel.loadedColor)
                                //protects text overflow
                                    .padding([.leading, .trailing],nil)
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
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    //                .aspectRatio(1, contentMode: .fit)
                    //                    .background(.thinMaterial)
                    //                    .cornerRadius(20)
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .aspectRatio(2, contentMode: .fit)
                .background(.thickMaterial)
                .background(targetUserColor ?? appModel.loadedColor)
                .cornerRadius(20)
                //            .padding([.bottom], 0)
                //            .padding([.top, .leading, .trailing], nil)
                
                
                
                
                
                
                LazyVGrid(columns: columns, spacing: nil) {
                    
                    
                    
                    VStack {
                        if let user = viewModel.user, let dateCreated = user.dateCreated {
                            // Calculate user's age in days
                            let calendar = Calendar.current
                            let currentDate = Date()
                            
                            if let userAge = calendar.dateComponents([.day], from: dateCreated, to: currentDate).day {
                                Text(userAge == 1 ? "\(userAge) day" : "\(userAge) days")
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
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thickMaterial)
                    .cornerRadius(20)
                    VStack{
                        NavigationLink {
                            //                            FriendsView(showSignInView: $showSignInView, appModel.loadedColor: $appModel.loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: viewModel.user?.userId ?? "")
                            FriendsView(targetUserId: viewModel.user?.userId ?? "")
                        } label: {
                            
                            VStack{
                                if let user = viewModel.user {
                                    if let friends = user.friends{
                                        Text(String(friends.count))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(targetUserColor ?? appModel.loadedColor)
                                        Text(friends.count == 1 ? "Friend" : "Friends")
                                            .font(.headline)
                                            .fontWeight(.regular)
                                    }
                                }
                            }
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth:.infinity, maxHeight: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                            
                        }
                        
                        
                        if targetUserId.isEmpty {
                            
                            NavigationLink {
                                //                                FriendRequestsView(showSignInView: $showSignInView, appModel.loadedColor: $appModel.loadedColor, showCreateProfileView: $showCreateProfileView, targetUserId: viewModel.user?.userId ?? "")
                                
                                FriendRequestsView(targetUserId: viewModel.user?.userId ?? "")
                            } label: {
                                
                                VStack{
                                    if let user = viewModel.user {
                                        if let incomingFriendRequests = user.incomingFriendRequests{
                                            friendRequests(incomingFriendRequests: incomingFriendRequests)
                                        }
                                    }
                                }
                                .foregroundColor(Color(UIColor.label))
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                                .background(.thinMaterial)
                                .cornerRadius(20)
                                
                            }
                            
                            
                        } else {
                            if  viewModel.isFriend != nil, viewModel.requestSent != nil, viewModel.requestedMe != nil {
                                Button {
                                    
                                    if viewModel.isFriend!{
                                        viewModel.removeFriend(friendUserId: targetUserId)
                                    } else {
                                        if viewModel.requestedMe! {
                                            viewModel.acceptFriendRequest(friendUserId: targetUserId)
                                            
                                        } else {
                                            viewModel.requestSent!
                                            ? viewModel.unsendFriendRequest(friendUserId: targetUserId)
                                            : viewModel.sendFriendRequest(friendUserId: targetUserId)
                                        }
                                    }
                                    
                                    
                                    
                                } label: {
                                    
                                    
                                    HStack{
                                        
                                        
                                        
                                        
                                        if viewModel.isFriend!{
                                            
                                            Label("Friended", systemImage: "person.crop.circle.badge.checkmark")
                                            
                                        } else {
                                            //                                                    let authDataResultUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                            if viewModel.requestedMe! {
                                                
                                                
                                                Label("Accept Request", systemImage: "person.badge.plus")
                                                
                                                
                                            } else {
                                                
                                                
                                                viewModel.requestSent!
                                                ? Label("Request Sent", systemImage: "paperplane")
                                                
                                                : Label("Add Friend", systemImage: "person.badge.plus")
                                                
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .tint(targetUserColor ?? appModel.loadedColor)
                                    //                                    .animation(.easeInOut, value: viewModel.isFriend!)
                                    .animation(nil, value: viewModel.isFriend!)
                                    .animation(nil, value: viewModel.requestSent!)
                                    
                                    
                                    .frame(maxWidth:.infinity, maxHeight: .infinity)
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
                                        if let startTime = pressStartTime {
                                            let duration = Date().timeIntervalSince(startTime)
                                            let tickleCount = Int(duration * 10)
                                            
                                            
                                            if !isPressing && tickleCount <= 1  {
                                                
                                                feedbackGenerator.impactOccurred()
                                                
                                                let currentUserId = try!  AuthenticationManager.shared.getAuthenticatedUser().uid
                                                //
                                                //
                                                Task {
                                                    try await tickleNotification(userId: targetUserId, count: tickleCount)
                                                }
                                                AnalyticsManager.shared.tickle(count: tickleCount)
                                            }
                                            
                                        }
                                        
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0) // Detects any drag or press
                                    .onChanged { _ in
                                        if !isPressing {
                                            isPressing = true
                                            pressStartTime = Date()
                                            startHapticFeedback()
                                        }
                                    }
                                    .onEnded { _ in
                                        if isPressing {
                                            isPressing = false
                                            stopHapticFeedback()
                                            
                                            if let startTime = pressStartTime {
                                                let duration = Date().timeIntervalSince(startTime)
                                                let tickleCount = Int(duration * 10)
                                                
                                                if tickleCount > 1 {
                                                    let currentUserId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
                                                    Task {
                                                        try await tickleNotification(userId: targetUserId, count: tickleCount)
                                                    }
                                                    AnalyticsManager.shared.tickle(count: tickleCount)
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                            )
                        
                        
                        Text(tickleString)
                            .font(tickleString == "Tickle" ? .title2 : .largeTitle)
                            .fontWeight(.bold)
                            .fontDesign(tickleString == "Tickle" ? .default : .monospaced)
                            .foregroundStyle(.secondary)
                            .frame(height:50)
                    }
                    
                    
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thinMaterial)
                            .aspectRatio(1, contentMode: .fit)
                        
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                    }
                    
                    
                    
                    
                }
                //            .padding()
                
                
                
            }
            .padding()
            
            Spacer()
            
            
            
            
            
        }
        
        .task{
            print(targetUserColor)
            print(appModel.loadedColor)
            print(targetUserId)
            targetUserId.isEmpty ?
            try? await viewModel.loadCurrentUser() :
            try? await viewModel.loadTargetUser(targetUserId: targetUserId)
            
            viewModel.checkFriendshipStatus()
            viewModel.checkRequestStatus()
            viewModel.checkRequestedMe()
            
            
        }
        
        .onDisappear(perform: {
            if isPressing {
                isPressing = false
                stopHapticFeedback()
                
                if let startTime = pressStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    let tickleCount = Int(duration * 10)
                    
                    if tickleCount > 1 {
                        let currentUserId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
                        
                        Task {
                            try await tickleNotification(userId: targetUserId, count: tickleCount)
                        }
                        AnalyticsManager.shared.tickle(count: tickleCount)
                    }
                }
            }
            
            
        })
        
        
        .navigationTitle("Profile 🤠")
        .toolbar{
            if (targetUserId.isEmpty) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
                        //                        SettingsView(showSignInView: $showSignInView)
                        
                        SettingsView()
                    } label: {
                        Image (systemName: "gear")
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
