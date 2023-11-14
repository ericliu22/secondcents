//
//  ParticleView.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 10/23/23.
//

import SwiftUI

@available(iOS 17.0, *)
struct ParticleView: View {
    @State private var beatAnimation: Bool = false
    @State private var showPulses: Bool = false
    @State private var pulsedHearts: [HeartParticle] = []
    var body: some View {
        ZStack{
            Color("SabotageBg")
                .edgesIgnoringSafeArea(.all)
            Image("eric-pic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 1000, height: 1000)
                .blur(radius: 80)
            VStack{
                ZStack{
                    if showPulses {
                        TimelineView(.animation(minimumInterval: 1.4, paused: false)) {
                            timeline in
                            Canvas { context, size in
                                for heart in pulsedHearts {
                                    if let resolvedView = context.resolveSymbol(id: heart.id) {
                                        let centerX = size.width / 2
                                        let centerY = size.height / 2
                                        
                                        context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY))
                                    }
                                }
                            } symbols: {
                                ForEach(pulsedHearts) {
                                    PulseHeartView()
                                        .id($0.id)
                                }
                            }
                            .onChange(of: timeline.date) { oldValue, newValue in
                                if beatAnimation {
                                    addPulsedHeart()
                                }
                            }
                        }
                    }
                    ZStack{
                        Image(systemName: "suit.heart.fill")
                            .font(.system(size: 150))
                            .foregroundStyle(Color("ericPurple").gradient)
                            .symbolEffect(.bounce, options: beatAnimation ? .repeating.speed(0.1) : .default, value: beatAnimation)
//                            .onAppear{
//                                beatAnimation = true
//                            }
                        Text("")
                            .font(.custom("LuckiestGuy-Regular", size: 64))
                   
                        
                            .foregroundStyle(Color("ericPurple"))
                            .offset(y: 200)
                    }
                }
                .frame(maxWidth: 350, maxHeight: 500)
//                .overlay(RoundedRectangle(cornerRadius: 20)
////                    .stroke(Color("ericPurple"), lineWidth: 5)
//                    .fill(.purple.opacity(0.1))
//                )
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
                
                Toggle("Beat Animation", isOn: $beatAnimation)
                    .padding(15)
                    .frame(maxWidth: 350)
                    .background(.bar, in: .rect(cornerRadius: 20))
                    .padding(.top, 20)
                    
                    .onChange(of: beatAnimation) { oldValue, newValue in
                        if pulsedHearts.isEmpty {
                            showPulses = true
                        }
                        
                        if newValue && pulsedHearts.isEmpty {
                            addPulsedHeart()
                        }
                    }
            }   //vstack
        }
    }
    
    func addPulsedHeart() {
        let pulsedHeart = HeartParticle()
        pulsedHearts.append(pulsedHeart)
        
        //Removing after the pulse animation is finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            pulsedHearts.removeAll(where: { $0.id == pulsedHeart.id })
            
            if pulsedHearts.isEmpty {
                showPulses = false
            }
        }
    }
}

// Pulsed Heart Animation View

struct PulseHeartView: View {
    @State private var startAnimation: Bool = false
    var body: some  View {
        Image(systemName: "suit.heart.fill")
            .font(.system(size: 120))
            .foregroundStyle(Color("ericPurple").gradient)
            .scaleEffect(startAnimation ? 4 : 1)
            .opacity(startAnimation ? 0 : 0.3)
            .onAppear(perform: {
                withAnimation(.linear(duration: 3)){
                    startAnimation = true
                }
            })
    }
}

@available(iOS 17.0, *)
struct ParticleView_Previews: PreviewProvider {
    static var previews: some View {
        ParticleView()
    }
}
