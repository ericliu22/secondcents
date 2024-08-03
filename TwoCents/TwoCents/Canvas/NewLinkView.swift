//
//  NewLinkView.swift
//  TwoCents
//
//  Created by Eric Liu on 24/8/3.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct NewLinkView: View {
    @State private var url: URL?
    @State var spaceId: String
    @State private var showingView: Bool = false
    var viewModel = NewLinkViewModel()
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismissScreen
    
    @Binding private var closeNewWidgetview: Bool
    
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetview = closeNewWidgetview
           
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self._closeNewWidgetview = .constant(false)
    }
    
    var body: some View {
        LinkView(url: url ?? URL(string: "https://twocentsapp.com")!)
            .disabled(true)
            .background(Color(UIColor.systemBackground))
            .onTapGesture {
                showingView.toggle()
            }
            .fullScreenCover(isPresented: $showingView, content: {
        NavigationStack{
            VStack {
                //preview block
                LinkPreview(link: $url)
                    .frame(width: 200, height: 200)
                // Text field for input
                    TextField("Enter text", text: Binding(
                            get: { url?.absoluteString ?? "" },
                            set: { url = URL(string: $0) }
                        ))
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                
                Button(action: {
                    
                    if let userId = viewModel.user?.userId {
                        
                        dismissScreen()
                        showingView = false
                        closeNewWidgetview = true
                        let newLink = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId, media: .link, mediaURL: url!)
                        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newLink)
                        
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
                .disabled(url == nil)
                .onAppear {
                    isTextFieldFocused = true // Add this line to focus text field on appear
                }
            }
            .navigationTitle("New Link 🔗")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button(action: {
                        showingView = false
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
            })
    
    }

}

struct LinkPreview: View {
    
    @Binding var link: URL?
    
    var body: some View {
        if let link = link {
            LinkView(url: link)
        } else {
            Text("Enter a link")
        }
    }
    
}
