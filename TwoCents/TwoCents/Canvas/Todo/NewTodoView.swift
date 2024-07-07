//
//
//  NewPoll.swift
//  TwoCents
//
//  Created by Joshua Shen on 2/16/24.
//

import Foundation
import SwiftUI
import Charts

struct NewTodoView: View{
    private var spaceId: String
    @StateObject private var viewModel: NewTodoModel
    
    @State private var showingView: Bool = false
    
    @State private var userColor: Color = Color.gray
    
    @Binding private var closeNewWidgetview: Bool
    
    
    let todoList = ["Cape cod chips", "Jolibee", "Speaker","Disposable camera"]
    
    let todoListColor: [Color] = [.orange, .blue, .red, .green]
    
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
        //        self.pollModel = NewPollModel(spaceId: spaceId)
        _viewModel = StateObject(wrappedValue:NewTodoModel(spaceId: spaceId))
        
        self._closeNewWidgetview = closeNewWidgetview
        
    }
    
    @State var todoArray: [String] = [""]
    
    @State private var mentionedUserIds: [String] = [""]
    
    
    @State private var mentionedUserNames: [String] = [""]
    
    @State private var mentionedUserColors: [Color] = [.gray]
    
    var body: some View{
        ZStack{
            
            
            TodoWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .todo, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
            
            
            
            Color(UIColor.tertiarySystemFill)
                .ignoresSafeArea()
            
            
            
            
            VStack(alignment: .leading, spacing:0){
                
                HStack{
                    
                    //Event Name
                    Text("Boys Night")
                        .font(.headline)
                        .foregroundColor(Color.accentColor)
                        .fontWeight(.bold)
                    
                    
                    
                    
                }
                
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 5)
                
                
                
                //                Spacer()
                //                    .frame(height: 3)
                
                
                //todo list
                ForEach(todoList.indices, id: \.self) { index in
                    HStack(spacing: 5) {
                        todoListColor[index]
                            .frame(width: 3.75, height: 15)
                            .cornerRadius(3.75)
                        
                        Text(todoList[index])
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.label))
                            .truncationMode(.tail)
                            .lineLimit(1)
                        
                    }
                    .padding(.bottom, 5)
                }
                .padding(.horizontal, 20)
                
                
                HStack(spacing: 3.75) {
                    Color.secondary
                        .frame(width: 3.75, height: 15)
                        .cornerRadius(3.75)
                    
                    Text("+2 more")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .truncationMode(.tail)
                        .lineLimit(1)
                    
                }
                .padding(.horizontal, 20)
                
                
                
                Spacer()
                
                
                
            }
            
//            .frame(width: 250, height: 250)
            .background(Color(UIColor.systemBackground))
//            .cornerRadius(30)
            
            
            
            .overlay(
                
                
                VStack{
                    
                    
                    HStack{
                        
                        Spacer()
                        Text("6")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 15)
                            .padding(.trailing, 20)
                        
                    }
                    
                    Spacer()
                    
                    
                    
                    
                    
                }
            )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        }
        
        .frame(width: .infinity, height: .infinity)
        .onTapGesture{showingView.toggle()}
        .fullScreenCover(isPresented: $showingView, content: {
            NavigationStack{
                ZStack{
                    
                    //main contents
                    VStack{
                        
                        newTodoSection
                        addItemSection
                        Button(action: {
                            //@TODO: Replace with NewWidgetView temp widget behavior
                            Task{
                                
                                
                                viewModel.addItem(todoArray: todoArray)
                                await viewModel.createNewTodo()
                                showingView = false
                                
                                closeNewWidgetview = true
                                
                            }
                        }, label: {
                            Text("Submit")
                                .font(.headline)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                            //                            .foregroundStyle(Color.accentColor)
                        })
                        .disabled(
                            viewModel.listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || todoArray .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        )
                        //                                    .disabled(pollModel.isCreateNewPollButtonDisabled)
                        .buttonStyle(.bordered)
                        //                    .foregroundColor(Color.accentColor)
                        .frame(height: 55)
                        .cornerRadius(10)
                        
                    }
                    
                    .padding()
                }
                .navigationTitle("Create List 📋")
                .toolbar{
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(action: {
                            
                            showingView = false
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.label))
                            
                        })
                    }
                }
            }
        })
        .task {
            userColor = try! await Color.fromString(name: UserManager.shared.getUser(userId: AuthenticationManager.shared.getAuthenticatedUser().uid).userColor ?? "")
        }
    }
    
    var newTodoSection: some View{
        Section{
        } header: {
            TextField("List Name", text: $viewModel.listName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(userColor)
        }
    }
    
    var addItemSectionTextField: some View{
        Section() {
            VStack{
            }
        }
    }
    
    
    var addItemSection: some View{
        VStack {
            ForEach(todoArray.indices, id: \.self) { index in
                
                
                
                HStack{
                    
                 
                    TextField("Item \(index + 1)", text:
                                $todoArray[index]
                              
                    )
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                   
//                    
//                    Button(action: {
//                        
//                        
//                        
//                    }, label: {
//                        Image(systemName: "at.badge.plus")
//                    
//                            .frame(width: 54, height: 54)
//                        
//                          
//                    })
//                    .frame(width: 54, height: 54)
//                    .cornerRadius(10)
//                    .buttonStyle(.bordered)
//                    
                    
           
                    
                    NavigationLink {
                        MentionFriendsView(mentionedUser: $mentionedUserIds[index])
                            .onDisappear(perform: {
                                Task {
                                    do {
                                        // Fetch user name safely with error handling
                                        let userName = try await viewModel.getUserName(userId: mentionedUserIds[index])
                                        
                                        let userColor = try await viewModel.getUserColor(userId: mentionedUserIds[index])
                                        mentionedUserNames[index] = userName
                                        mentionedUserColors[index] = userColor
                                    } catch {
                                        print("Failed to fetch user name: \(error)")
                                        // Optionally handle the error, e.g., set a default value or show an alert
                                        mentionedUserNames[index] = "Unknown User"
                                    }
                                }
                                
                            })
                    } label: {
                        
                        if mentionedUserIds[index] == ""  || mentionedUserNames[index] == "" {
                            Image(systemName: "at.badge.plus")
                                .padding(.horizontal)
                                .frame( height: 54)
                                .background(Color(UIColor.secondarySystemBackground))
                            
                        } else {
                            Text(mentionedUserNames[index])
               
                                .padding(.horizontal)
                                .frame( height: 54)
                                .background(.regularMaterial)
                                .background(mentionedUserColors[index])
                                .foregroundColor(mentionedUserColors[index])
                        }
                      
                   
                        
                        
                    }
               
                    .cornerRadius(10)

                }
                
            }
            .onChange(of: todoArray.last) { oldValue, newValue in
                //                print(newValue)
                if newValue != "" && todoArray.count <= 3{
                    todoArray.append("")
                    mentionedUserIds.append("")
                    mentionedUserNames.append("")
                    mentionedUserColors.append(.gray)
                }
            }
            
            
            
            
            
        }
    }
}


#Preview {
    NavigationStack{
        NewTodoView(spaceId: "099E9885-EE75-401D-9045-0F6DA64D29B1", closeNewWidgetview: .constant(false))
    }
}

