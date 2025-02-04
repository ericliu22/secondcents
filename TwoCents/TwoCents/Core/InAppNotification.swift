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
    @State private var spaceId: String = ""
    @State private var widgetId: String = ""
    
    
    // How long the notification stays on screen
    private let displayDuration: CGFloat = 3.0
    
    @State private var barProgress: Double = 100.0
    @State private var progress: Double = 100.0 // Start at 100
    
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
                    ProgressView(value: barProgress, total: 100)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding([.top, .bottom], 3)
                        .tint(Color(.white))
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
        .onTapGesture {
            print(spaceId)
            print(widgetId)
            if !spaceId.isEmpty && !widgetId.isEmpty {
                appModel.navigationRequest = .space(spaceId: spaceId, widgetId: widgetId)
            }
        }
        // Animate the transition in/out
        .animation(.easeInOut, value: presented)
        // Respond to changes in notificationRequest
        .onChange(of: appModel.notificationRequest) { newValue in
            guard case .notification(let newTitle, let newMessage, let newSpaceId, let newWidgetId) = newValue else {
                return
            }
            
            // Set the content
            self.title = newTitle
            self.message = newMessage
            if let newSpaceId {
                self.spaceId = newSpaceId
            }
            if let newWidgetId {
                self.widgetId = newWidgetId
            }

            // Present the banner
            self.presented = true
            self.progress = 0  // reset progress in case a second notification triggers quickly
            self.barProgress = 100
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation(.linear(duration: 3)) {
                    self.barProgress -= 100
                }
            }
            
            // After 3 seconds, hide the banner and reset everything
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                self.presented = false
                self.progress = 0
                self.barProgress = 100
                appModel.notificationRequest = .none
            }
        }
    }
}

//struct TestBarView: View{
//    @State private var progress: Double = 100.0 // Start at 100
//    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect() // Fires every 0.5 seconds
//    var body: some View{
//        ZStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Test Title")
//                        .font(.headline)
//                    Text("Test Message")
//                        .font(.subheadline)
//                    
//                    // @TODO: Progress bar at the bottom of the banner
//                    ProgressView(value: progress, total: 100)
//                        .progressViewStyle(LinearProgressViewStyle())
//                        .padding()
//                        .tint(Color(UIColor.systemBackground))
//                }
//                .foregroundColor(.white)
//                .background(Color(.blue))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//                .cornerRadius(8)
//                .shadow(radius: 5)
//                .padding()
//                // Slide in from top
//                .transition(.move(edge: .top))
//                // When the view first appears, animate the progress bar
//            }.onReceive(timer) { _ in
//                //print("start timer")
//                        if progress > 0 {
//                            withAnimation(.linear(duration: 3)) { // Animate decrease
//                                progress -= 100
//                            }
//                        }
//                    }
//        }
//    }
//
//
//
//struct notificationBuilder_Previews: PreviewProvider {
//    static var previews: some View {
//        TestBarView()
//    }
//}



