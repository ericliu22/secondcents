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
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.pollModel = NewPollModel(spaceId: spaceId)
    }
    
    var body: some View{
        VStack{
            newPollSection
            addOptionSection
            Button(action: {
                //@TODO: Replace with NewWidgetView temp widget behavior
                Task{await pollModel.createNewPoll()}
            }, label: {
                Text("Submit")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            })
            .disabled(pollModel.isCreateNewPollButtonDisabled)
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .frame(height: 55)
                .cornerRadius(10)
                
        }.padding()
    }
    
    var newPollSection: some View{
        Section{
        } header: {
            TextField("Poll Name", text: $pollModel.newPollName)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                .foregroundStyle(Color.accentColor)
        } footer: {
            Text("2-10 options")
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
            TextField("Enter option name", text: $pollModel.newOptionName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            Button("+ Add Option") {
                pollModel.addOption()
            }.disabled(pollModel.isAddOptionsButtonDisabled)
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

/*
 #Preview{
 NavigationStack{newPoll()}
 }
 */
