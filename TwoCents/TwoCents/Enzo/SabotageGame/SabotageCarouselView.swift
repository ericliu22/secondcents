//
//  SabotageCarouselView.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 12/4/23.
//

import SwiftUI

struct SabotageCarouselView: View {
    
    
    // Properties...
    var spacing: CGFloat = 15
    var trailingSpace: CGFloat = 100
    @Binding var index: Int
    
//    init(index: Binding<Int>) {
//        self._index = index
////        self.player = player
//    }
    
    //Offset...
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    @State var counter: Int = 0
    
    @State private var beatAnimation: Bool = false
    @State private var showPulses: Bool = false
    @State private var pulsedHearts: [HeartParticle] = []
//    var player: DBUser
    
    var playerIndex: Int
    

    var body: some View {
        GeometryReader{proxy in
            
            //Setting correct width
            
            let width = proxy.size.width - (100 - spacing)
            let adjustmentWidth = (100 / 2) - spacing
            
            HStack(spacing: spacing){

                
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "theatermasks.fill", sabotageText: "Pretend", specificIndex: 0, counter: $counter, playerIndex: playerIndex)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "shuffle", sabotageText: "Change Profile", specificIndex: 1, counter: $counter, playerIndex: playerIndex)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "trash.fill", sabotageText: "Delete Widgets", specificIndex: 2, counter: $counter, playerIndex: playerIndex)
                    .frame(width: proxy.size.width - 100)
                SabotageCarouselWidget(currentIndex: $currentIndex, icon: "delete.left.fill", sabotageText: "Remove points", specificIndex: 3, counter: $counter, playerIndex: playerIndex)
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
    
//    var player: PlayerData
    
    var playerIndex: Int
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
                        .foregroundStyle(.purple.gradient)
                        .symbolEffect(.bounce, options: specificIndex == currentIndex ? .repeating.speed(0.01) : .default, value: currentIndex)
                            .onAppear{
                                counter = 5
                            }
                    Text(sabotageText)
                        .font(.custom("LuckiestGuy-Regular", size: 32))
                        .foregroundStyle(.purple.gradient)
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


#Preview {
    SabotageCarouselView(index: .constant(0), playerIndex: 0)
}
