//
//  TextWidgetAlpha.swift
//  TwoCents
//
//  Created by Joshua Shen on 5/22/24.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct TextView: View {
    //@StateObject private var nvm = NewWidgetViewModel()
    @State private var inputText: String = ""
//    @Binding var showPopup: Bool
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismissScreen
    var body: some View {
        NavigationStack{
            VStack {
               
                    
               
                    
                    
                    //preview block
                    Text(inputText)
                        .multilineTextAlignment(.leading)
                        .font(.custom("LuckiestGuy-Regular", size: 40, relativeTo: .headline))
                        .padding(25/3)
                        .frame(width: 250, height: 250)
                        .minimumScaleFactor(0.8)
                        .background(.ultraThickMaterial)
                        .background(Color.accentColor)
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(30)
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
                    if !inputText.isEmpty {
                        let newText = CanvasWidget(borderColor: Color.accentColor, userId: "fOBAypBOWBVkpHEft3V3Dq9JJgX2", media: .text, textString: inputText)
                        SpaceManager.shared.uploadWidget(spaceId: "865CE76B-9948-4310-A2C7-5BE32B302E4A", widget: newText)
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
                
                .onAppear {
                    isTextFieldFocused = true // Add this line to focus text field on appear
                }
            }
            .navigationTitle("New Text 🗣️")
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
            
        }
     
        
        
      
    
    
    }
      
    

}
