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

struct NewMapView: View{
    private var spaceId: String
//    @StateObject private var pollModel: NewPollModel
    
    @State private var showingView: Bool = false
    
    @State private var userColor: Color = Color.gray
    
    @Binding private var closeNewWidgetview: Bool
   
    
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId

//        _pollModel = StateObject(wrappedValue:NewPollModel(spaceId: spaceId))
        
        self._closeNewWidgetview = closeNewWidgetview
           
    }
    
    @State var OptionsArray: [String] = [""]
    
    var body: some View{
        ZStack {
                   DisplayLocationWidgetView(latitude: "40.7791151", longitude: "-73.9626129")
               }
        .frame(width: .infinity, height: .infinity)
               .contentShape(Rectangle()) // Make the whole area tappable
               .onTapGesture {
                   showingView.toggle()
                   print("tapped")
               }
        
        .fullScreenCover(isPresented: $showingView, content: {
            NavigationStack{
                ZStack{
                    SetLocationWidgetView(userColor: $userColor, closeNewWidgetview: $closeNewWidgetview, spaceId: spaceId)
                      
                }
                .navigationTitle("Select Location 📍")
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
                }
            }
            
      
        })
        .task {
            guard let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
                userColor = Color.fromString(name: "gray")
                return
            }
            guard let color = try? await UserManager.shared.getUser(userId: userId).userColor else {
                userColor = Color.fromString(name: "gray")
                return
            }
            userColor = Color.fromString(name: color)
            
        }
    }
    
   
}

#Preview {
    NavigationStack{
        NewMapView(spaceId: "099E9885-EE75-401D-9045-0F6DA64D29B1", closeNewWidgetview: .constant(false))
    }
}
 
