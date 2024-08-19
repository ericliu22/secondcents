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

    var sortedTodoItems: [TodoItem] {
        viewModel.localTodoList.sorted { !$0.completed && $1.completed }
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
      
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                dismissScreen()
                withAnimation {
                    viewModel.saveChanges(spaceId: spaceId, todoId: widget.id.uuidString)
                }
            }, label: {
                Text("Done")
            })
        }
        
        
        
            
            
            ToolbarItem(placement: .bottomBar) {
                
                Button(action: {
                    viewModel.autoAssignTasks(spaceId: spaceId)
                    
                }, label: {
                    
                    
                    Text("Auto Assign Tasks")
                    
                })
                .disabled(viewModel.allUsers.isEmpty)
                
            }
        
        
        
        
        
    }

    var body: some View {
        if let todo = viewModel.todo {
            NavigationStack {
                ScrollView {
                    VStack {
                        ForEach(Array(sortedTodoItems.enumerated()), id: \.element.id) { index, todoItem in
                            
                            let originalIndex = viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0
                            
                            
                            HStack(spacing: 0) {
                                
                                Button(action: {
                                    withAnimation {
                                        // Find the index of the todoItem in the original list
                                        
                                        viewModel.toggleCompletionStatus(index: originalIndex)
                                    }
                                }) {
                                    Image(systemName: todoItem.completed ? "circle.inset.filled" : "circle")
                                        .foregroundColor(todoItem.completed ? Color.fromString(name: viewModel.mentionedUsers[viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0]?.userColor ?? "") : .gray)
                                        .font(.title3)
                                }
                                .padding(.trailing)
                                
                                TextField("Item \(index)", text: $viewModel.localTodoList[originalIndex].task)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                
                                Spacer()
                                NavigationLink {
                                    MentionUserView(mentionedUser: $viewModel.mentionedUsers[viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0], allUsers: viewModel.allUsers)
                                        .onDisappear(perform: {
                                            viewModel.modifiedMentionedUsers[viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0] = viewModel.mentionedUsers[viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0]?.id ?? ""
                                        })
                                } label: {
                                    UserChip(user: viewModel.mentionedUsers[viewModel.localTodoList.firstIndex(where: { $0.id == todoItem.id }) ?? 0])
                                }
                                .disabled(viewModel.allUsers.isEmpty)
                                
                            }
                            .frame(height: 48)
                            .padding(.horizontal)
                            .contextMenu(ContextMenu(menuItems: {
                                Button (role: .destructive){
                                    viewModel.deleteItem(index: originalIndex, todoItemId: todoItem.id, spaceId: spaceId, todoId: widget.id.uuidString)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                  
                                }

                            }))
                            Divider()
                        }
                    
                        
                        Group{
                            HStack(spacing: 0) {
                                
                                
                                Image(systemName: "circle.badge.plus")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                    .padding(.trailing)
                                
                                
                                
                                TextField("New Item", text: $viewModel.newTodoItem.task)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onChange(of: viewModel.newTodoItem.task, { oldValue, newValue in
                                        
                                        if newValue != "" && oldValue == "" {
                                            Task{
                                                withAnimation {
                                                    viewModel.saveChanges(spaceId: spaceId, todoId: widget.id.uuidString)
                                                }
                                            }
                                        }
                                    })
                                    .onSubmit {
                                        viewModel.addNewTodoItem(spaceId: spaceId, todoId: widget.id.uuidString)
                                        
                                        
                                    }
                                
                                
                                Spacer()
                                
                            
                                
                                
                                
                                
                                
                            }
                            .frame(height: 48)
                            .padding(.horizontal)
                            Divider()
                            
                            
                            
                        }
                        
                        
                        Spacer()
                            .frame(height:300)
                        
                        
                        Spacer()
                    }
                    .navigationTitle(todo.name)
                    .toolbar {toolbar()}
                }
            }
            .onDisappear(perform: {
                viewModel.saveChanges(spaceId: spaceId, todoId: widget.id.uuidString)
            })
//            .interactiveDismissDisabled(true)
            .task{
                
                try? await viewModel.getAllUsers(spaceId: spaceId)
            }
           
            
        } else {
            ProgressView()
               
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
                .frame(width: 100, alignment: .trailing)
            } else {
                Image(systemName: "at.badge.plus")
                    .frame(height: 54, alignment: .trailing)
            }
        }
    }
}
