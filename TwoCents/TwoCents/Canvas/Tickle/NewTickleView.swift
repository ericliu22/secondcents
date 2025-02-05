//
//  NewTickleView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/4.
//

import SwiftUI

struct NewTickleView: View {
    let spaceId: String
    @Binding var closeNewWidgetview: Bool
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        NavigationLink {
            NewTicklePage(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
        } label: {
            if let userId = appModel.user?.userId {
                TickleWidget(widget: CanvasWidget(borderColor: .black, userId: userId, media: .tickle))
            }
        }
    }
}

struct NewTicklePage: View {
    
    @Binding var closeNewWidgetview: Bool
    @Environment(AppModel.self) var appModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State var selectedUser: DBUser?

    let spaceId: String

    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetview = closeNewWidgetview
    }

    var body: some View {
        VStack {
            if canvasViewModel.members.isEmpty {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color(UIColor.label)))
            } else {
                ForEach(canvasViewModel.members) { member in

                    if member.userId != appModel.user?.userId {

                        let targetUserColor: Color =
                            Color.fromString(name: member.userColor ?? "gray")

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
                            Text(member.name!)
                                .font(.headline)
                            Spacer()

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.thickMaterial)
                        .tint(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedUser = member
                        }

                    }
                }
            }
            Button {
                guard let userId = selectedUser?.userId else {
                    return
                }
                let (width, height) = SpaceManager.shared.getMultipliedSize(widthMultiplier: 1, heightMultiplier: 1)
                let widget = CanvasWidget(width: width, height: height, borderColor: .black, userId: userId, media: .tickle)
                
                canvasViewModel.newWidget = widget
                canvasViewModel.canvasMode = .placement
                closeNewWidgetview = true
            } label: {
                Text("Create")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(selectedUser == nil ? .gray : .green)
            .frame(height: 55)
            .cornerRadius(10)
        }
    }

    
}
