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
    @State private var pollModel: NewPollModel
    @State private var showingView: Bool = false
    
   
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.pollModel = NewPollModel(spaceId: spaceId)
    }
    
    @State var OptionsArray: [String] = []
    
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
                
                
                //main cotnents
                VStack{
                    
                    newPollSection
                    addOptionSection
                    Button(action: {
                        //@TODO: Replace with NewWidgetView temp widget behavior
                        Task{
                            pollModel.addOptions(OptionArray: OptionsArray)
                            await pollModel.createNewPoll()
                            
                        }
                    }, label: {
                        Text("Submit")
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                    })
                    //                .disabled(pollModel.isCreateNewPollButtonDisabled)
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .frame(height: 55)
                    .cornerRadius(10)
                    
                }
                .padding()
            }
        })
    }
    
    var newPollSection: some View{
        Section{
        } header: {
            TextField("Poll Name", text: $pollModel.newPollName)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                .foregroundStyle(Color.accentColor)
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
            Button("+ Add Option") {
                //pollModel.addOption()
                //TODO: cannot add options if isempty or contains only spaces
                OptionsArray.append("")
               
            }/*.disabled(pollModel.isAddOptionsButtonDisabled)*/
                .buttonStyle(.borderedProminent)
                .tint(Color(Color.accentColor))
                .frame(height: 55)
                .cornerRadius(10)
            ForEach(pollModel.newPollOptions) { option in
                Text(option.name)
            }.onDelete{
                indexSet in
                pollModel.newPollOptions.remove(atOffsets: indexSet)
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
 
