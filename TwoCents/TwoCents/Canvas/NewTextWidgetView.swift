//
//  TextWidgetAlpha.swift
//  TwoCents
//
//  Created by Joshua Shen on 5/22/24.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct NewTextWidgetView: View {
    //@StateObject private var nvm = NewWidgetViewModel()
    @State private var inputText: String = ""
//    @Binding var showPopup: Bool
    
    @StateObject private var viewModel = NewTextWidgetViewModel()
    
    @State var spaceId: String
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismissScreen
    
    @Binding private var closeNewWidgetview: Bool
    
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId

//        _pollModel = StateObject(wrappedValue:NewPollModel(spaceId: spaceId))
        
        self._closeNewWidgetview = closeNewWidgetview
           
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId

//        _pollModel = StateObject(wrappedValue:NewPollModel(spaceId: spaceId))
        
        self._closeNewWidgetview = .constant(false)
           
    }
    
    
    
    var body: some View {
        NavigationStack{
            VStack {
               
                
                    
                    //preview block
                    Text(inputText)
                        .multilineTextAlignment(.leading)
                        .font(.custom("LuckiestGuy-Regular", size: 32, relativeTo: .headline))
                        .padding(20/3)
                        .frame(width: 200, height: 200)
                        .minimumScaleFactor(0.8)
                        .background(.ultraThickMaterial)
                        .background(Color.accentColor)
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(80/3)
                        .padding(.bottom)
                    
        
                
                // Text field for input
                TextField("Enter text", text: $inputText)
                //                    .textFieldStyle(RoundedBorderTextFieldStyle())
                //                    .padding()
                    .focused($isTextFieldFocused)
                
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                // Button to submit text
                
                Button(action: {
                    
                    
              
     
                    if let userId = viewModel.user?.userId {
                        
                        dismissScreen()
                        
                        closeNewWidgetview = true
                        let newText = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId, media: .text, textString: inputText)
                        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newText)
                        
                        inputText = ""
                        
                        
                        
                        
                    }
                    
                    
                    
                }, label: {
                    Text("Submit")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                    //                            .foregroundStyle(Color.accentColor)
                })
                //                .disabled(
                //                    pollModel.newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                //                    || OptionsArray .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                //                )
                //                                    .disabled(pollModel.isCreateNewPollButtonDisabled)
                .buttonStyle(.bordered)
                //                    .foregroundColor(Color.accentColor)
                .frame(height: 55)
                .cornerRadius(10)
                .disabled(inputText.isEmpty)
                .onAppear {
                    isTextFieldFocused = true // Add this line to focus text field on appear
                }
            }
            .navigationTitle("New Text 🗣️")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button(action: {
                        dismissScreen()
                        
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                        //                        .font(.title2)
                        //                        .padding()
                    })
                    
                    
                }
                
            }
            .padding(.horizontal)
            
            
            .task {
                try? await viewModel.loadCurrentUser()
                
//                try? await viewModel.loadCurrentSpace(spaceId: spaceId)
                
               
                
            }
            
            
            
            
        }
     
        
        
      
    
    
    }
      
    

}
