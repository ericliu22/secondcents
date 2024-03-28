//
//  NewPoll.swift
//  TwoCents
//
//  Created by Joshua Shen on 2/16/24.
//

import Foundation
import SwiftUI

struct newPoll: View{
    @State private var zm = FunctionModel()
    
    var body: some View{
        VStack{
            newPollSection
            addOptionSection
//            Button("submit") {
//                Task{await zm.createNewPoll()}
//                //Task{zm.createNewPoll}
//            }
            Button(action: {
                Task{await zm.createNewPoll()}
            }, label: {
                Text("Submit")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            })
            .disabled(zm.isCreateNewPollButtonDisabled)
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .frame(height: 55)
                .cornerRadius(10)
                
        }.padding()
    }
    
    var newPollSection: some View{
        Section{
        } header: {
            TextField("Poll Name", text: $zm.newPollName)
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
        Section ("Options") {
            TextField("Enter option name", text: $zm.newOptionName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            Button("+ Add Option") {
                zm.addOption()
            }.disabled(zm.isAddOptionsButtonDisabled)
                .buttonStyle(.borderedProminent)
                .tint(Color(Color.accentColor))
                .frame(height: 55)
                .cornerRadius(10)
            ForEach(zm.newPollOptions) {
                Text($0)
            }.onDelete{
                indexSet in
                zm.newPollOptions.remove(atOffsets: indexSet)
            }
        }
    }
}

extension String: Identifiable{
    public var id: Self { self }
}

#Preview{
    NavigationStack{newPoll()}
}
