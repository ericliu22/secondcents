//
//
//  NewPoll.swift
//  TwoCents
//
//  Created by Joshua Shen on 2/16/24.
//

import Foundation
import SwiftUI

struct NewPoll: View{
    private var spaceId: String
    @StateObject private var pollModel: NewPollModel
    
    @State private var showingView: Bool = false
    
    @State private var userColor: Color = Color.gray
    
   
    
    init(spaceId: String) {
        self.spaceId = spaceId
//        self.pollModel = NewPollModel(spaceId: spaceId)
        _pollModel = StateObject(wrappedValue:NewPollModel(spaceId: spaceId))
           
    }
    
    @State var OptionsArray: [String] = [""]
    
    var body: some View{
        VStack{
            //Poll widgets must have a name lest they crash
            Text("New Poll")
        }
        .frame(width: 250, height: 250)
        .onTapGesture{showingView.toggle()}
        .fullScreenCover(isPresented: $showingView, content: {
            
            ZStack{
                
                
                //cross to dismiss screen
                ZStack (alignment: .topLeading) {
                    
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                    
                    Button(action: {
                        showingView = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                            .font(.title2)
                            .padding()
                    })
                }
                
                
                //main contents
                VStack{
                    
                    newPollSection
                    addOptionSection
                    Button(action: {
                        //@TODO: Replace with NewWidgetView temp widget behavior
                        Task{
                            
                            
                            pollModel.addOptions(OptionArray: OptionsArray)
                            await pollModel.createNewPoll()
                            showingView = false
                            
                            
                        }
                    }, label: {
                        Text("Submit")
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(Color.accentColor)
                    })
                    .disabled(
                        pollModel.newPollName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || OptionsArray .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    )
                    //                                    .disabled(pollModel.isCreateNewPollButtonDisabled)
                    .buttonStyle(.bordered)
//                    .foregroundColor(Color.accentColor)
                    .frame(height: 55)
                    .cornerRadius(10)
                    
                }
               
                .padding()
            }
      
        })
        .task {
            userColor = try! await Color.fromString(name: UserManager.shared.getUser(userId: AuthenticationManager.shared.getAuthenticatedUser().uid).userColor ?? "")
            
        }
    }
    
    var newPollSection: some View{
        Section{
        } header: {
            TextField("Poll Name", text: $pollModel.newPollName)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                .foregroundStyle(userColor)
        }
        
    }
    
    var addOptionSectionTextField: some View{
        Section() {
            VStack{
            }
        }
    }
    
    
    var addOptionSection: some View{
        VStack {
            ForEach(OptionsArray.indices, id: \.self) { index in
                TextField("Enter option name", text:
                            $OptionsArray[index]
                    //$pollModel.newOptionName
                )
                
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .onChange(of: OptionsArray.last) { oldValue, newValue in
//                print(newValue)
                if newValue != "" && OptionsArray.count <= 3{
                    OptionsArray.append("")
                }
            }
           
        }
    }
}

extension String: Identifiable{
    public var id: Self { self }
}


#Preview {
    NavigationStack{
        NewPoll(spaceId: "099E9885-EE75-401D-9045-0F6DA64D29B1")
    }
}
 
