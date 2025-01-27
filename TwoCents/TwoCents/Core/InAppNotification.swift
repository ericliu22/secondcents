//
//  InAppNotification.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/27.
//
import SwiftUI

struct InAppNotification: View {
    
    @Environment(AppModel.self) var appModel
    @State var presented: Bool = false
    @State var title: String = ""
    @State var message: String = ""

    var body: some View {
        VStack {
            if presented {
                VStack {
                    Text(title)
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    Text(message)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(appModel.loadedColor)
                .cornerRadius(8)
                .shadow(radius: 5)
                .padding()
            }
        }
        .onChange(of: appModel.notificationRequest) {
            guard case .notification(let title, let message) = appModel.notificationRequest else {
                return
            }
            
            print(title)
            print(message)
            self.title = title
            self.message = message
            self.presented = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.presented = false
                appModel.notificationRequest = .none
            }
        }
    }
    
}
