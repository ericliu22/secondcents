//
//  File.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI

struct pollSheet: View{
    
    @Environment(\.presentationMode) var presentationMode
    
    var fm = FunctionModel()
    
    var vm = pollViewModel(pollId: "6sWahoac9ACFWQxWmvhG")
    
    var body: some View{
        ZStack{
            pollSection
        }.onAppear{
            fm.listenToLivePolls()
            vm.listenToPoll()
            //see PollFunctions for implementation
        }
    }
    
    var pollSection: some View{
        ForEach(fm.polls){ poll in
            ZStack(alignment: .topLeading) {
                Color.white.edgesIgnoringSafeArea(.all)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding(20)
                })
                VStack(){
                    Text(poll.name)
                        .padding(.top, 10)
                    if let options = vm.poll?.options{
                        Section{
                            PollChartView(options: options)
                        }
                        Section("Vote") {
                            ForEach(options) {
                                option in
                                Button(action: {
                                    vm.incrementOption(option)
                                }, label: {
                                    HStack{
                                        Text(option.name)
                                            .foregroundColor(.black)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview{
    pollSheet(vm: .init(pollId: "6sWahoac9ACFWQxWmvhG"))
}
