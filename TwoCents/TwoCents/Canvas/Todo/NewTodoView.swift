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
        _viewModel = StateObject(wrappedValue: NewTodoModel(spaceId: spaceId))
        self._closeNewWidgetview = closeNewWidgetview
        
    }
    
    @State var todoArray: [String] = ["", "", "", ""]
    
    @State private var mentionedUsers: [DBUser?] = [nil, nil, nil, nil]
    
    
    
    
    var body: some View{
        ZStack{
            
            
            
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
                
                ScrollView {
                    //main contents
                    VStack{
                        
                        newTodoSection
                        addItemSection
                        
                    }
                    
//                    .padding()
                    
                }
                
                .navigationTitle("Create List 📋")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(action: {
                            
                            showingView = false
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.label))
                            
                        })
                    }
                    
               
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            
                            viewModel.addItem(todoArray: todoArray, userArray: mentionedUsers)
                            Task{
                                await viewModel.createNewTodo()
                            }
                            showingView = false
                            
                            closeNewWidgetview = true
                        }, label: {
                            Text("Create")
                        })
                        .disabled(
                            viewModel.listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || todoArray .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        )
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
                .padding(.horizontal)
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
                
                
                
                HStack(spacing:0){
                    
                    
                    TextField("Item \(index + 1)", text:
                                $todoArray[index]
                              
                    )
//                    .padding()
//                    .background(Color(UIColor.secondarySystemBackground))
//                    .cornerRadius(10)
                   
                    .submitLabel(.next)
                    
                    
                    
                    
                    NavigationLink {
                        MentionUserView(mentionedUser: $mentionedUsers[index], spaceId: spaceId)
                        
                    } label: {
                        
                            UserChip(user: mentionedUsers[index])
                            .frame(height: 48)
                       
                        
                    }
                    
                    
                }
                .padding(.horizontal)
                
//                .background(/*mentionedUsers[index] == nil ? Color.clear :*/ Color(UIColor.secondarySystemBackground))
                
                
//                .cornerRadius(10)
                
                Divider()
                
            }
            .onChange(of: todoArray.last) { oldValue, newValue in
                
                if newValue != "" /*&& todoArray.count <= 3*/{
                    todoArray.append("")
                    mentionedUsers.append(nil)
                    
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
//                .padding(.horizontal)
                .frame(height: 54, alignment: .trailing)
        }
    }
}
