//
//  ContentView.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 7/24/23.
//

import SwiftUI

private let fixedColumns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]//gay

struct HotSeatGame: View {
    @State var scale = 0.5
    let baseAnimation = Animation.easeInOut(duration: 1)
    
    var body: some View {
        
            NavigationView{
                ZStack {
                    Color("universalOrange")
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HotSeatText()
                        ImageDisplayed(imageDisplayed: "josh-pic")
                            .scaleEffect(scale)
                            .onAppear {
                                withAnimation(baseAnimation) {
                                    scale = 1
                                }
                            }
                        
                        TextDisplayed(textDisplayed: "Who would you like to interrogate?", textSize: 24)
                            .padding(.bottom, -15)
                        
                        ScrollView{
                            LazyVGrid(columns: fixedColumns, spacing: 20) {
                                ForEach(0..<playerData.count, id: \.self) { item in
                                    NavigationLink(destination: secondView(color: playerData[item].color, profilePicture: playerData[item].image, profileName: playerData[item].name), label: {Image(playerData[item].image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 175, height: 175)
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                } 
            }
        }
}

struct secondView: View {
    @State private var message = ""
    @State var savedMessage = ""
    @State private var readyNext = false
    var color: String
    var profilePicture: String
    var profileName: String
    
    var body: some View {
        ZStack {
            Color("universalOrange")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HotSeatText()
                ImageDisplayed(imageDisplayed: profilePicture)
                Text("What is your _burning question_ to")
                    .font(.custom("SFProDisplay-Regular", size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 75)
                Text("\(profileName)?")
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, -5)
                
                    TextField("Dear Mr. \(profileName)...", text: $message)
                        .padding(.all, 20)
                        .keyboardType(.default)
                        .background(.white).cornerRadius(40)
                        .overlay(Capsule().stroke(Color(color), lineWidth: 5))
                        .padding()
                
                    .padding()
                Button("Send") {
                    saveText()
                    self.readyNext = true
                }
                .font(.custom("LuckiestGuy-Regular", size: 48))
                .foregroundColor(.white)
                .opacity(message == "" ? 0.5: 1.0)
                .disabled(message == "")
                
                NavigationLink(destination: thirdView(profilePicture: profilePicture, profileName: profileName, color: color, dataArray: savedMessage), isActive: $readyNext) {EmptyView()}


                
                Spacer()
            }
        }.navigationBarBackButtonHidden(true)
    }
    func saveText() {
        savedMessage = message
    }
}

struct thirdView: View {
    var profilePicture: String
    var profileName: String
    var color: String
    
    @State private var animateOpacity = 0.0
    @State var dataArray: String
    
    var body: some View {
        ZStack{
            Color("universalOrange")
                .edgesIgnoringSafeArea(.all)
            VStack{
                ImageDisplayed(imageDisplayed: "josh-pic")
                    .onAppear {
                        animateOpacity = 1.0
                    }
                    .opacity(animateOpacity)
                    .animation(.default.delay(1), value: animateOpacity)
                Text("has requested a")
                    .foregroundColor(.white)
                    .onAppear {
                        animateOpacity = 1.0
                    }
                    .opacity(animateOpacity)
                    .animation(.default.delay(2), value: animateOpacity)
                HotSeatText()
                    .onAppear {
                        animateOpacity = 1.0
                    }
                    .opacity(animateOpacity)
                    .animation(.default.delay(3), value: animateOpacity)
                Spacer()
                NavigationLink(destination: fourthView(dataArray: dataArray, hotSeatManager: HotSeatManager(), color: color, profilePicture: profilePicture, profileName: profileName), label: {Text("_Continue_")
                        .font(.custom("SFProDisplay-Regular", size: 28))
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .padding(.bottom, 30)
                }).onAppear {
                    animateOpacity = 1.0
                }
                .opacity(animateOpacity)
                .animation(.default.delay(4), value: animateOpacity)
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct fourthView: View {
    @State private var message = ""
    @State var dataArray: String
    @State private var animateOpacity = 0.0
    @State private var isMessageShown = false
    @Namespace private var textAnimation
    @ObservedObject var hotSeatManager: HotSeatManager
    @State private var response = ""
    @State private var savedResponse = ""
    @State private var shouldHide = false
    @State private var delayOpacity = false


    var color: String
    var profilePicture: String
    var profileName: String
    
    var body: some View {
        ZStack{
            Color("universalOrange")
                .edgesIgnoringSafeArea(.all)
            if isMessageShown {
                continuedView
            } else {loadView}
        }.navigationBarBackButtonHidden(true)
    }
    
    var loadView: some View {
        VStack{
            HotSeatText()
                .padding(.top, 10)
                .padding(.bottom, -20)
                .onAppear {
                    animateOpacity = 1.0
                }
                .opacity(animateOpacity)
                .animation(.default.delay(1), value: animateOpacity)
            
            ImageDisplayed(imageDisplayed: profilePicture)
                .opacity(animateOpacity)
                .animation(.default.delay(1), value: animateOpacity)
            
            Text("Dear")
                .font(.custom("LuckiestGuy-Regular", size: 32))
                .matchedGeometryEffect(id: "id1", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.leading, 30)
                .padding(.top, 10)
                .opacity(animateOpacity)
                .animation(.default.delay(2), value: animateOpacity)
            
            Text(profileName)
                .font(.custom("SFProDisplay-Regular", size: 24))
                .matchedGeometryEffect(id: "id2", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.leading, 30)
                .opacity(animateOpacity)
                .animation(.default.delay(3), value: animateOpacity)
            
            Text(dataArray)
                .font(.custom("LuckiestGuy-Regular", size: 40))
                .matchedGeometryEffect(id: "id3", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.top, 25)
                .opacity(animateOpacity)
                .animation(.default.delay(4), value: animateOpacity)
            Spacer()
            Text("Continue")
                .font(.custom("SFProDisplay-RegularItalic", size: 24))
                .foregroundColor(.white)
                .opacity(animateOpacity)
                .animation(.default.delay(6), value: animateOpacity)
                .opacity(0.5)
                .onTapGesture{
                    withAnimation(.spring()) {
                        isMessageShown.toggle()
                        animateOpacity = 0.0
                    }
                }
            
        }
    }
    
    
    
    var continuedView: some View {
        VStack{
            Text("Dear")
                .font(.custom("LuckiestGuy-Regular", size: 32))
                .matchedGeometryEffect(id: "id1", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.leading, 30)
                .padding(.top, 10)
            
            Text(profileName)
                .font(.custom("SFProDisplay-Regular", size: 24))
                .matchedGeometryEffect(id: "id2", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.leading, 30)
            
            Text(dataArray)
                .font(.custom("LuckiestGuy-Regular", size: 40))
                .matchedGeometryEffect(id: "id3", in: textAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.top, 25)
            
            textFieldGroup
                .padding(.top, 25)
            Text(savedResponse)
                .font(.custom("LuckiestGuy-Regular", size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.top, 25)
                .opacity(delayOpacity ? 1.0: 0.0)
                .animation(.default.delay(1), value: delayOpacity)

            Spacer()
        }
    }
    
    
    
    var textFieldGroup: some View {
        VStack{
            if hotSeatManager.onHotSeat{
                HStack{
                    Image(profilePicture)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    TextField("What's your response?", text: $response)
                        .padding(.all, 20)
                        .keyboardType(.default)
                        .background(.white).cornerRadius(40)
                        .overlay(Capsule().stroke(Color(color), lineWidth: 5))
                        .padding(.trailing, 20)
                        .frame(height: shouldHide ? 0: nil)
                        .opacity(shouldHide ? 0: animateOpacity)
                }
                .padding(.top, 20)
                .padding(.leading, 15)
                .onAppear {
                    animateOpacity = 1.0
                }
                .opacity(animateOpacity)
                .animation(.default.delay(2), value: animateOpacity)
                
                Button("Send") {
                    saveResponse()
                    shouldHide.toggle()
                    delayOpacity.toggle()
                }
                    .font(.custom("LuckiestGuy-Regular", size: 32))
                    .opacity(response == "" ? 0.5 : 1.0)
                    .foregroundColor(Color(color))
                    .padding(.top, 14)
                    .padding(.bottom, 7)
                    .padding(.horizontal, 40)
                    .background(
                        Capsule(style: .circular)
                            .fill(Color(.white))
                            .opacity(response == "" ? 0.5 : 1.0)
                    )
                    .opacity(animateOpacity)
                    .animation(.default.delay(2), value: animateOpacity)
                    .frame(width: shouldHide ? 0: nil, height: shouldHide ? 0: nil)
                    .opacity(shouldHide ? 0: animateOpacity)
                    .disabled(response == "")
                
            } else {
                HStack{
                    Image(profilePicture)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    Text("_\(profileName) is typing..._")
                        .foregroundColor(.white)
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 15)
                .onAppear {
                    animateOpacity = 1.0
                }
                .opacity(animateOpacity)
                .animation(.default.delay(2), value: animateOpacity)
            }
        }
    }
    func saveResponse(){
        savedResponse = response
    }
}

struct HotSeatText: View {
    var body: some View {
        Text("HOT SEAT")
            .font(.custom("LuckiestGuy-Regular", size: 64))
            .foregroundColor(.white)
            .padding()
    }
}

struct TextDisplayed: View {
    var textDisplayed: String
    var textSize: Int

    var body: some View {
        Text(textDisplayed)
            .font(.custom("SFProDisplay-Regular", size: CGFloat(textSize)))
            .foregroundColor(.white)
            .padding()
    }
}

struct ImageDisplayed: View {
    var imageDisplayed: String
    var body: some View {
        Image(imageDisplayed)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
    }
}

struct HotSeatGame_Preview: PreviewProvider {
    static var previews: some View {
        HotSeatGame()
        secondView(color: playerData[0].color, profilePicture: playerData[0].image, profileName: playerData[0].name)
        thirdView(profilePicture: playerData[0].image, profileName: playerData[0].name, color: playerData[0].color, dataArray: "hi")
        fourthView(dataArray: "How are you today?", hotSeatManager: HotSeatManager(), color: playerData[0].color, profilePicture: playerData[0].image, profileName: playerData[0].name)
    }
}
