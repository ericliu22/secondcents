//
//  TodoWidgetSheetView.swift
//  TwoCents
//
//  Created by jonathan on 7/8/24.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct TodoWidgetSheetView: View {
    
    let widget: CanvasWidget
    private var spaceId: String
    
    @StateObject private var viewModel = TodoWidgetSheetViewModel()
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .todo)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    @Environment(\.dismiss) var dismissScreen
    
    var body: some View {
        if let todo = viewModel.todo {
            NavigationStack {
                ScrollView {
                    VStack {
                        ForEach(todo.todoList.indices, id: \.self) { index in
                            let todoItem = todo.todoList[index]
                            
                            HStack(spacing: 0) {
                                Text(todoItem.task)
                                Spacer()
                                NavigationLink {
                                    MentionUserView(mentionedUser: $viewModel.mentionedUsers[index], spaceId: spaceId)
                                        .onDisappear(perform: {
                                            if let userId = viewModel.mentionedUsers[index]?.id {
                                                let todoId = widget.id.uuidString
                                                viewModel.updateMentionedUser(spaceId: spaceId, todoId: todoId, index: index, mentionedUserId: userId)
                                            }
                                        })
                                } label: {
                                    UserChip(user: viewModel.mentionedUsers[index])
                                }
                            }
                            .frame(height: 48)
                            .padding(.horizontal)
                            Divider()
                        }
                        Spacer()
                    }
                    .navigationTitle(todo.name)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                dismissScreen()
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.label))
                            })
                        }
                    }
                }
            }
        } else {
            ProgressView()
                .backgroundStyle(Color(UIColor.systemBackground))
                .onAppear {
                    viewModel.fetchTodo(spaceId: spaceId, widget: widget)
                }
        }
    }
    
    struct UserChip: View {
        let user: DBUser?
        
        var body: some View {
            if let user = user {
                let targetUserColor: Color = Color.fromString(name: user.userColor ?? "")
                HStack {
                    Group {
                        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 16, height: 16)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                    .scaleEffect(0.5, anchor: .center)
                                    .frame(width: 16, height: 16)
                                    .background(
                                        Circle()
                                            .fill(targetUserColor)
                                            .frame(width: 16, height: 16)
                                    )
                            }
                        } else {
                            Circle()
                                .strokeBorder(targetUserColor, lineWidth: 0)
                                .background(Circle().fill(targetUserColor))
                                .frame(width: 16, height: 16)
                        }
                    }
                    Text(user.name ?? "Unavailable")
                        .font(.headline)
                        .foregroundStyle(Color(UIColor.label))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2.5)
                .background(.thickMaterial, in: Capsule())
                .background(targetUserColor, in: Capsule())
                .frame(width: 100)
            } else {
                Image(systemName: "at.badge.plus")
                    .padding(.horizontal)
                    .frame(height: 54, alignment: .trailing)
            }
        }
    }
}
