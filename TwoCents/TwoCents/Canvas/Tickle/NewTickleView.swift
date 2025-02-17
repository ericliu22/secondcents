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
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    @State private var showingView: Bool = false
    @State private var selectedUser: DBUser?

    var body: some View {
        if let userId = appModel.user?.userId {
            TickleWidget(widget: CanvasWidget(borderColor: .red, userId: userId, media: .tickle))
                .onTapGesture { showingView.toggle() }
                .fullScreenCover(isPresented: $showingView) {
                    NavigationStack {
                        ScrollView {
                            VStack {
                                if canvasViewModel.members.isEmpty {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.label)))
                                } else {
                                    ForEach(canvasViewModel.members) { member in
                                        if member.userId != appModel.user?.userId {
                                            let targetUserColor: Color = Color.fromString(name: member.userColor ?? "gray")
                                            
                                            HStack(spacing: 20) {
                                                if let urlString = member.profileImageUrl, let url = URL(string: urlString) {
                                                    CachedImage(imageUrl: url)
                                                        .clipShape(Circle())
                                                        .frame(width: 64, height: 64)
                                                } else {
                                                    Circle()
                                                        .fill(targetUserColor)
                                                        .frame(width: 64, height: 64)
                                                }
                                                
                                                Text(member.name ?? "Unknown User")
                                                    .font(.headline)
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(selectedUser?.userId == member.userId ? Color.gray.opacity(0.2) : Color.clear)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedUser = member
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { showingView = false }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color(UIColor.label))
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    if let userId = selectedUser?.userId {
                                        let (width, height) = getMultipliedSize(widthMultiplier: 1, heightMultiplier: 1)
                                        let widget = CanvasWidget(width: width, height: height, borderColor: .black, userId: userId, media: .tickle)
                                        
                                        canvasViewModel.newWidget = widget
                                        canvasViewModel.canvasMode = .placement
                                        closeNewWidgetview = true
                                    }
                                }, label: {
                                    Text("Create")
                                })
                                .disabled(selectedUser == nil)
                            }
                        }
                    }
                }
        }
    }
}
