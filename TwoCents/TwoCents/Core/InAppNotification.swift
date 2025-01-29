//
//  InAppNotification.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/27.
//
import SwiftUI

struct InAppNotification: View {
    @Environment(AppModel.self) var appModel
    
    // Controls visibility and content
    @State private var presented: Bool = false
    @State private var title: String = ""
    @State private var message: String = ""
    
    // Progress bar state
    @State private var progress: CGFloat = 0.0
    
    // How long the notification stays on screen
    private let displayDuration: CGFloat = 3.0
    
    var body: some View {
        // A ZStack or VStack can both work.
        // ZStack is often used so the banner can slide over the current view.
        ZStack(alignment: .top) {
            if presented {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                    
                    Text(message)
                        .font(.subheadline)
                    
                    // @TODO: Progress bar at the bottom of the banner
                    
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(appModel.loadedColor)
                .cornerRadius(8)
                .shadow(radius: 5)
                .padding()
                // Slide in from top
                .transition(.move(edge: .top))
                // When the view first appears, animate the progress bar
            }
        }
        // Animate the transition in/out
        .animation(.easeInOut, value: presented)
        // Respond to changes in notificationRequest
        .onChange(of: appModel.notificationRequest) { newValue in
            guard case .notification(let newTitle, let newMessage) = newValue else {
                return
            }
            
            // Set the content
            self.title = newTitle
            self.message = newMessage
            
            // Present the banner
            self.presented = true
            self.progress = 0  // reset progress in case a second notification triggers quickly
            
            // After 3 seconds, hide the banner and reset everything
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                self.presented = false
                self.progress = 0
                appModel.notificationRequest = .none
            }
        }
    }
}
