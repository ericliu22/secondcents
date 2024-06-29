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

struct NewPoll: View{
    private var spaceId: String
    @StateObject private var pollModel: NewPollModel
    
    @State private var showingView: Bool = false
    
    @State private var userColor: Color = Color.gray
    
    
    
    @Binding private var closeNewWidgetview: Bool
   
    
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
//        self.pollModel = NewPollModel(spaceId: spaceId)
        _pollModel = StateObject(wrappedValue:NewPollModel(spaceId: spaceId))
        
        self._closeNewWidgetview = closeNewWidgetview
           
    }
    
    @State var OptionsArray: [String] = [""]
    
    var body: some View{
        ZStack{
            //Poll widgets must have a name lest they crash
//            Text("New Poll")
            let values = [5, 4, 8, 9]
               let colors: [Color] =  [.red,  .orange, .green, .cyan]
            
            
            
               
            
            Chart {
                       ForEach(0..<values.count, id: \.self) { index in
                           SectorMark(
                               angle: .value("Vote", values[index]),
                               innerRadius: .ratio(0.618),
                               angularInset: 2
                           )
                           .foregroundStyle(colors[index])
                           .cornerRadius(3)
                       }
                   }
            
//                   .frame(height: 300)
                   .padding()
                  
//                .foregroundStyle(colorForIndex(index: poll!.options.firstIndex(of: option)!))
                                                                
//            }
           
        
            
            VStack{
                Text("26")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(userColor)
                Text("Votes")
                    .font(.headline)
                    .fontWeight(.regular)
                //                                        .fill(.ultraThickMaterial)
                    .foregroundStyle(userColor)
//
//                            .padding(.bottom)
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
            
            
              
                
              
            
            
            
            
        }

        .frame(width: .infinity, height: .infinity)
        .background(.ultraThickMaterial)
        .onTapGesture{showingView.toggle()}
        .fullScreenCover(isPresented: $showingView, content: {
            NavigationStack{
                ZStack{
                    
                    
//                    //cross to dismiss screen
//                    ZStack (alignment: .topLeading) {
//                        
//                        Color.clear
//                            .edgesIgnoringSafeArea(.all)
//                        
//                        Button(action: {
//                            showingView = false
//                        }, label: {
//                            Image(systemName: "xmark")
//                                .foregroundColor(Color(UIColor.label))
//                                .font(.title2)
//                                .padding()
//                        })
//                    }
                    
                    
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
                                
                                closeNewWidgetview = true
                                
                                
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
                .navigationTitle("Create Poll 🤓")
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
            userColor = try! await Color.fromString(name: UserManager.shared.getUser(userId: AuthenticationManager.shared.getAuthenticatedUser().uid).userColor ?? "")
            
        }
    }
    
    var newPollSection: some View{
        Section{
        } header: {
            TextField("Enter a Question", text: $pollModel.newPollName)
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
                TextField("Option \(index + 1)", text:
                            $OptionsArray[index]
                    //$pollModel.newOptionName
                )
                
//                    .autocorrectionDisabled()
//                    .textInputAutocapitalization(.never)
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
        NewPoll(spaceId: "099E9885-EE75-401D-9045-0F6DA64D29B1", closeNewWidgetview: .constant(false))
    }
}
 
