//
//  SabotageGame.swift
//  TwoCentsUI
//
//  Created by Enzo Tanjutco on 8/31/23.
//

import SwiftUI


private let fixedColumns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct SabotageView: View {
    
    @State var isSpread = false
    var body: some View {
        NavigationStack{
            ZStack{
                Color("SabotageBg")
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("Who will be the victim of your")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                    Text("Sabotage")
                        .foregroundColor(.white)
                        .font(.custom("LuckiestGuy-Regular", size: 60))
                        .padding(.top, -10)
                    Spacer()
                    ZStack{
                        ForEach(0..<playerData.count, id: \.self) { player in
                            CardView(player: playerData[player], playerIndex: player, isSpread: $isSpread) 
//                                .onAppear{
//                                    isSpread = true
//                                }
                                .rotationEffect(.degrees(isSpread ? CGFloat((player*5)+5) : 0))
//                                .animation(Animation.spring(
//                                    response: 1.0,
//                                    dampingFraction: 5).repeatForever().delay(1), value: isSpread)
//                                .offset(x: isSpread ? CGFloat(player*20) : 0)
                        }
                    }
                    Spacer()
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        isSpread.toggle()
                    }
                }
            }
        }
    }
}

struct SabotageSelectionView: View {
    @State var currentIndex: Int = 0
    @State var posts: [PostModel] = []
    var player: PlayerData
    
    var body: some View {
        ZStack{
            
            VStack{
                HStack(spacing: 0){
                }
                
                SabotageCarouselView(index: $currentIndex, player: player)
                .padding(.vertical, 40)
                
                HStack(spacing: 10) {
                    ForEach(posts.indices, id: \.self) { index in
                        Circle()
                            .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentIndex == index ? 1.4 : 1)
                            .animation(.spring(), value: currentIndex == index)
                    }
                }
            }
        }
        .background(
            ZStack{
                Color("SabotageBg")
                    .edgesIgnoringSafeArea(.all)
                Image(player.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 1000, height: 1000)
                    .blur(radius: 80)
            }
            )
        .frame(maxWidth: .infinity, alignment: .top)
        .onAppear {
            for index in 1...4 {
                posts.append(PostModel(postImage: "post\(index)"))
//                print("The posts are: \(posts)")
            }
        }
    }
}

struct SabotageCarouselView: View {
    
    
    // Properties...
    var spacing: CGFloat = 15
    var trailingSpace: CGFloat = 100
    @Binding var index: Int
    
    init(index: Binding<Int>, player: PlayerData) {
        self._index = index
        self.player = player
    }
    
    //Offset...
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    @State var counter: Int = 0
    
    @State private var beatAnimation: Bool = false
    @State private var showPulses: Bool = false
    @State private var pulsedHearts: [HeartParticle] = []
    var player: PlayerData
    

    var body: some View {
        GeometryReader{proxy in
            
            //Setting correct width
            
            let width = proxy.size.width - (100 - spacing)
            let adjustmentWidth = (100 / 2) - spacing
            
            HStack(spacing: spacing){

                
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "theatermasks.fill", sabotageText: "Pretend", specificIndex: 0, counter: $counter, player: player)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "shuffle", sabotageText: "Change Profile", specificIndex: 1, counter: $counter, player: player)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "trash.fill", sabotageText: "Delete Widgets", specificIndex: 2, counter: $counter, player: player)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "delete.left.fill", sabotageText: "Remove points", specificIndex: 3, counter: $counter, player: player)
                    .frame(width: proxy.size.width - 100)
                
                
            }
            .padding(.horizontal,spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustmentWidth: 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        
                        //were going to convert the translation into progress (0-1)
                        //and round the value
                        //based on shit
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), 4 - 1), 0)
                        
                        //updating Index
                        currentIndex = index
                        counter = counter + 1
                        print(currentIndex)
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        
                        //were going to convert the translation into progress (0-1)
                        //and round the value
                        //based on shit
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), 4 - 1), 0)
                    })
            )
        }
        //animating when offset = 0
        .animation(.easeInOut, value: offset == 0)
        
    }
    

}

struct SabotageCarouselWidget: View {
    @State private var beatAnimation: Bool = false
    @State private var showPulses: Bool = false
    @State private var pulsedHearts: [HeartParticle] = []
    
    @Binding var currentIndex: Int
    
    var icon: String
    var sabotageText: String
    
    var specificIndex: Int
    
    @Binding var counter: Int
    
    var player: PlayerData
    var body: some View {
        VStack{
            ZStack{
//                if showPulses {
//                    TimelineView(.animation(minimumInterval: 1.5, paused: false)) {
//                        timeline in
//                        Canvas { context, size in
//                            for heart in pulsedHearts {
//                                if let resolvedView = context.resolveSymbol(id: heart.id) {
//                                    let centerX = size.width / 2
//                                    let centerY = size.height / 2
//                                    
//                                    context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY))
//                                }
//                            }
//                        } symbols: {
//                            ForEach(pulsedHearts) {
//                                SabotagePulseHeartView(iconPulse: icon, player: player)
//                                    .id($0.id)
//                            }
//                        }
//                        .onChange(of: timeline.date) { oldValue, newValue in
//                            if beatAnimation {
//                                addPulsedHeart()
//                            }
//                        }
//                    }
//                }
                ZStack{
                    Image(systemName: icon)
                        .font(.system(size: 120))
                        .foregroundStyle(player.nativeColor.gradient)
                        .symbolEffect(.bounce, options: specificIndex == currentIndex ? .repeating.speed(0.01) : .default, value: currentIndex)
                            .onAppear{
                                counter = 5
                            }
                    Text(sabotageText)
                        .font(.custom("LuckiestGuy-Regular", size: 32))
                        .foregroundStyle(player.nativeColor)
                        .offset(y: 200)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(player.color), lineWidth: 5))
            .background(specificIndex == currentIndex ? .green : .red, in: .rect(cornerRadius: 30))
            
//            Toggle("Beat Animation", isOn: $beatAnimation)
//                .padding(15)
//                .frame(maxWidth: 350)
//                .background(.bar, in: .rect(cornerRadius: 15))
//                .padding(.top, 20)
//                
//                .onChange(of: beatAnimation) { oldValue, newValue in
//                    if pulsedHearts.isEmpty {
//                        showPulses = true
//                    }
//                    
//                    if newValue && pulsedHearts.isEmpty {
//                        addPulsedHeart()
//                    }
                }
        }
    }
//    func addPulsedHeart() {
//        let pulsedHeart = HeartParticle()
//        pulsedHearts.append(pulsedHeart)
//        
//        //Removing after the pulse animation is finished
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            pulsedHearts.removeAll(where: { $0.id == pulsedHeart.id })
//            
//            if pulsedHearts.isEmpty {
//                showPulses = false
//            }
//        }
//    }
//}

// Pulsed Heart Animation View

//struct SabotagePulseHeartView: View {
//    @State private var startAnimation: Bool = false
//    var iconPulse: String
//    var player: PlayerData
//    var body: some  View {
//        Image(systemName: iconPulse)
//            .font(.system(size: 120))
//            .foregroundStyle(Color(player.color).gradient)
//            .scaleEffect(startAnimation ? 4 : 1)
//            .opacity(startAnimation ? 0 : 0.3)
//            .onAppear(perform: {
//                withAnimation(.linear(duration: 3)){
//                    startAnimation = true
//                }
//            })
//    }
//}

struct SabotageGamePretendReal: View {
    
    @State private var sabotageMessage = ""
    var player: PlayerData
    
    var body: some View {
        ZStack{
            Color("SabotageBg")
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("What's on your mind")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                Text("'\(player.name)'")
                    .foregroundColor(.white)
                    .font(.custom("LuckiestGuy-Regular", size: 30))
                ZStack{
                    Image(player.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .offset(x: -165, y: -55)
                        .zIndex(10)
                    TextField("Type here!", text: $sabotageMessage)
                        .padding(.all, 20)
                        .padding(.vertical, 15)
                        .keyboardType(.default)
                        .background(.white).cornerRadius(100)
                        .overlay(Capsule().stroke(Color(player.color), lineWidth: 5))
                        .padding()
                }
            }
        }
    }
}

struct SabotageGameChangePicReal: View {
    var player: PlayerData
    var body: some View {
        Text("change pic")
    }
}

struct SabotageGameDeleteReal: View {
    var player: PlayerData
    var body: some View {
        Text("delete widgets")
    }
}

struct SabotageGameRemovePointsReal: View {
    var player: PlayerData
    var body: some View {
        Text("remove points")
    }
}

struct SabotageWidgetReal: View {
    
    var player: PlayerData
    var icon: String
    var sabotageText: String
    
    var body: some View {
        ZStack{
            VStack{
                Image(systemName: icon)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(player.color))
                
                Text(sabotageText)
                    .foregroundColor(Color(player.color))
                    .font(.headline)
                    .fontWeight(.regular)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        
    }
    
}


@available(iOS 17.0, *)
struct SabotageView_Previews: PreviewProvider {
    static var previews: some View {
        SabotageView()
    }
}
