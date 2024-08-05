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
    @State private var rawURLString: String = ""
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
    
    var formattedURL: URL? {
        let trimmedURLString = rawURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else {
            return nil
        }
        if let url = URL(string: trimmedURLString), url.scheme != nil {
            return url
        } else {
            return URL(string: "https://\(trimmedURLString)")
        }
    }
    
    var body: some View {
        LinkView(url: formattedURL ?? URL(string: "https://twocentsapp.com")!)
            .disabled(true)
            .background(Color(UIColor.systemBackground))
            .onTapGesture {
                showingView.toggle()
            }
            .fullScreenCover(isPresented: $showingView, content: {
                NavigationStack {
                    VStack {
                        // Preview block
                        LinkPreview(link: $rawURLString)
                            .frame(width: 200, height: 200)
                        // Text field for input
                        TextField("Enter text", text: $rawURLString)
                            .focused($isTextFieldFocused)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Button(action: {
                            if let userId = viewModel.user?.userId, let url = formattedURL {
                                print("User ID: \(userId), URL: \(url.absoluteString)")
                                dismissScreen()
                                showingView = false
                                closeNewWidgetview = true
                                let newLink = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId, media: .link, mediaURL: url)
                                SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newLink)
                            } else {
                                print("Error: User ID or URL is nil")
                            }
                        }, label: {
                            Text("Submit")
                                .font(.headline)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.bordered)
                        .frame(height: 55)
                        .cornerRadius(10)
                        .disabled(rawURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .onAppear {
                            isTextFieldFocused = true // Add this line to focus text field on appear
                        }
                    }
                    .navigationTitle("New Link 🔗")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingView = false
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.label))
                            })
                        }
                    }
                    .padding(.horizontal)
                    .task {
                        try? await viewModel.loadCurrentUser()
                    }
                }
            })
    }
}

struct LinkPreview: View {
    @Binding var link: String
    
    var body: some View {
        if !link.isEmpty {
            if let url = URL(string: link.hasPrefix("https://") ? link : "https://\(link)") {
                LinkView(url: url)
            } else {
                Text("Invalid link")
            }
        } else {
            Text("Enter a link")
        }
    }
}
