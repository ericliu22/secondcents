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
        VStack{
            ZStack{
                if showPulses {
                    TimelineView(.animation(minimumInterval: 0.7, paused: false)) {
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
                Image(systemName: "suit.heart.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, options: !beatAnimation ? .default : .repeating.speed(1), value: beatAnimation)
                
            }
            .frame(maxWidth: 350, maxHeight: 350)
            .background(.bar, in: .rect(cornerRadius: 30))
            
            Toggle("Beat Animation", isOn: $beatAnimation)
                .padding(15)
                .frame(maxWidth: 350)
                .background(.bar, in: .rect(cornerRadius: 15))
                .padding(.top, 20)
                .onChange(of: beatAnimation) { oldValue, newValue in
                    if pulsedHearts.isEmpty {
                        showPulses = true
                    }
                    
                    if newValue && pulsedHearts.isEmpty {
                        addPulsedHeart()
                    }
                }
//                .disabled(!beatAnimation && pulsedHearts.isEmpty)
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
            .font(.system(size: 100))
            .foregroundStyle(.blue)
            .scaleEffect(startAnimation ? 4 : 1)
            .opacity(startAnimation ? 0 : 0.7)
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
