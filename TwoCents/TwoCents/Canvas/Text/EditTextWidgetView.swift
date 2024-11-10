//
//  EditTextWidgetView.swift
//  TwoCents
//
//  Created by Joshua Shen on 10/27/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct EditTextWidgetView: View {
    //@StateObject private var nvm = NewWidgetViewModel()
//    @State private var inputText: String
//    @Binding var showPopup: Bool
    @Environment(AppModel.self) var appModel

    @StateObject private var viewModel = EditTextWidgetViewModel()
    @State var inputText: String
    
    @State private var user: DBUser? = nil
    
    private var spaceId: String
    private var widget: CanvasWidget
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .text)
        self.widget = widget
        self.spaceId = spaceId
        self.inputText = widget.textString ?? ""
        print("Input Text:"+self.inputText)
        print("Widget Text String:"+(widget.textString ?? ""))
    }
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismissScreen

    var body: some View {
        NavigationStack{
            VStack {
                    //preview block
                Text(widget.textString ?? "")
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
//                        .onAppear{
//                            Task{
//                                try? await viewModel.loadWidgetTextString(spaceId: spaceId, widgetId: widgetId)
//                            }
//                        }
                    
        
                
                //Text field for input
                TextField("Enter text", text: $inputText)
                //                    .textFieldStyle(RoundedBorderTextFieldStyle())
                //                    .padding()
                    .focused($isTextFieldFocused)
                
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                 //Button to submit text
                
                Button(action: {
                    
                    
              
     
                    if let userId = appModel.user?.id {
                        
                        dismissScreen()
//                        let newText = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId, media: .text, textString: viewModel.WidgetTextString)
//                        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newText)
                        viewModel.uploadEditedText(spaceId: spaceId, text: inputText, widgetId: widget.id)
                        
                        viewModel.WidgetTextString = ""
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
                .disabled(((viewModel.WidgetTextString?.isEmpty) != nil))
                .onAppear {
                    isTextFieldFocused = true // Add this line to focus text field on appear
                }
            }
            .navigationTitle("Digital Footprint?")
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
            
            
//            .task {
//                try? await viewModel.loadCurrentUser()
//
////                try? await viewModel.loadCurrentSpace(spaceId: spaceId)
//            }
        }
    }
}
