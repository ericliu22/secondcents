//
//  chattingView.swift
//  TwoCents
//
//  Created by Joshua Shen on 8/12/23.
//

import Foundation
import SwiftUI
import UIKit

struct Message: Identifiable, Codable {
    var id: String
    var sendBy: String
    var text: String
    var ts: Date
}

struct chatStruct: View{
    @StateObject var messageManager = MessageManager()
    var body: some View{
        ForEach(messageManager.messages, id:\.id) {
            message in messageBubble(message: message)
        }
    }
}

struct messageBubble: View{
    var message: Message

    var body: some View{
        Text(message.text)
    }
}

struct chattingView: View {
    var body: some View {
        VStack{
            newChatView()
        }
    }
}

struct chattingView_Previews: PreviewProvider {
    static var previews: some View {
        chattingView()
    }
}

//originally part of separate file

struct newChatView: View {
    @State var Tapped = false
    //check for data to use this boolean
    var body: some View{
        VStack{
            ScrollView{
                LazyVStack{
                    UserBubble2()
                    UserBubble3()
                    chatStruct()
                    //unwrap data into view
                }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            }.frame(width: Tapped ? 300: 200, height: Tapped ? 700: 200).overlay(RoundedRectangle(cornerRadius:20).stroke(Tapped ? .white : .black, lineWidth: 2))
                .onTapGesture {
                    withAnimation(.spring()){
                        Tapped.toggle()
                    }
                }
            if Tapped{
                TextField("message...", text: .constant("")).frame(width: 300).textFieldStyle(.roundedBorder).background(Color(red: 220/256, green: 220/256, blue: 220/256))
            }
        }
    }
}

//text user 2 --> foreign
struct UserBubble2: View{
    var body: some View{
        VStack{
            Text("User2").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)).frame(maxWidth: .infinity, alignment: .leading)
            HStack{
            VStack{
                Text("Beautiful app tbh").padding(EdgeInsets(top: 0, leading: 10, bottom: 2, trailing: 10))
            }.background(LinearGradient(gradient: Gradient(colors: [Color(red: 240/256, green: 252/256, blue: 66/256), Color(red: 249/256, green: 255/256, blue: 194/256)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(15)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}
//test user 3 --> self
struct UserBubble3: View{
    var body: some View{
        VStack{
            Text("User3").padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).frame(maxWidth: .infinity, alignment: .trailing)
            HStack{
            VStack{
                Text("nice").padding(EdgeInsets(top: 0, leading: 10, bottom: 2, trailing: 10))
            }.background(LinearGradient(gradient: Gradient(colors: [Color(red: 252/256, green: 106/256, blue: 106/256), Color(red: 252/256, green: 53/256, blue: 53/256)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(15)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}

struct UserBubble4: View{
    var body: some View{
        VStack{
            Text("User3").padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)).frame(maxWidth: .infinity, alignment: .trailing)
            HStack{
                VStack{
                    Text("nice").padding(EdgeInsets(top: 0, leading: 10, bottom: 2, trailing: 10))
                }.background(LinearGradient(gradient: Gradient(colors: [Color(red: 252/256, green: 106/256, blue: 106/256), Color(red: 252/256, green: 53/256, blue: 53/256)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(15)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}
