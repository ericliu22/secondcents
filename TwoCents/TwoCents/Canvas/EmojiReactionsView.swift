//
//  EmotionalReactions.swift

import SwiftUI

struct EmojiReactionsView: View {
    @State private var heartCount = 0
    @State private var thumbsUpCount = 0
    @State private var thumbsDownCount = 0
    @State private var cryCount = 0
    @State private var questionCount = 0
    @State private var fingerCount = 0
    @State private var isLoved = false
    @State private var isLiked = false
    
    
    let inboundBubbleColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    let reactionsBGColor = Color(#colorLiteral(red: 0.05490196078, green: 0.09019607843, blue: 0.137254902, alpha: 1))
    var body: some View {
        HStack(spacing: 10) {
            Button {
                heartCount += 1
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    isLoved.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
                        isLoved = false
                    }
                }
            } label: {
                ZStack {
                    SplashView()
                        .opacity(isLoved ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: isLoved)
                        .scaleEffect(isLoved ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: isLoved)
                    
                    SplashView()
                        .rotationEffect(.degrees(90))
                        .opacity(isLoved ? 0 : 1)
                        .offset(y: isLoved ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: isLoved)
                        .scaleEffect(isLoved ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: isLoved)
                    
                   Text("❤️")
                        .phaseAnimator([false, true], trigger: heartCount) { icon, scaleFromBottom in
                            icon
                                .scaleEffect(scaleFromBottom ? 1.5 : 1, anchor: .bottom)
                        } animation: { scaleFromBottom in
                                .bouncy(duration: 0.4, extraBounce: 0.4)
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: isLoved ? 0 : 4)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: isLoved)
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(.systemPink))
                                .hueRotation(.degrees(isLoved ? 300 : 200))
                                .scaleEffect(isLoved ? 1.15 : 0)
                                .animation(.easeInOut(duration: 0.5), value: isLoved)
                        )
                        
                }
            }
            
            Button {
                thumbsUpCount += 1
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    isLiked.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
                        isLiked = false
                    }
                }
            } label: {
                ZStack {
                  
                    SplashView()
                        .opacity(isLiked ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: isLiked)
                        .scaleEffect(isLiked ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: isLiked)
                    
                    SplashView()
                        .rotationEffect(.degrees(90))
                        .opacity(isLiked ? 0 : 1)
                        .offset(y: isLiked ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: isLiked)
                        .scaleEffect(isLiked ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: isLiked)
                    Text("👍")
                        .phaseAnimator([false, true], trigger: thumbsUpCount) { icon, scaleRotate in
                            icon
                                .rotationEffect(.degrees(scaleRotate ? -5 : 0), anchor: .bottomLeading)
                                .scaleEffect(scaleRotate ? 1.5 : 1)
                        } animation: { scaleRotate in
                                .bouncy(duration: 0.4, extraBounce: 0.4)
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: isLiked ? 0 : 4)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: isLiked)
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(.systemPink))
                                .hueRotation(.degrees(isLiked ? 300 : 200))
                                .scaleEffect(isLiked ? 1.15 : 0)
                                .animation(.easeInOut(duration: 0.5), value: isLiked)
                            
                        )
                }
                
            }
            
            Button {
                thumbsDownCount += 1
            } label: {
                Text("👎")
            }
            .phaseAnimator([false, true], trigger: thumbsDownCount) { icon, dislike in
                icon
                    .rotationEffect(.degrees(dislike ? -45 : 0), anchor: .leading)
                    .scaleEffect(dislike ? 1.5 : 1)
            } animation: { dislike in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            Button {
                cryCount += 1
            } label: {
                Text("😭")
            }
            .phaseAnimator([false, true], trigger: cryCount) { icon, crying in
                icon
                    .offset(y: crying ? -20 : 0)
                    .scaleEffect(crying ? 1.5 : 1)
            } animation: { crying in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            Button {
                fingerCount += 1
            } label: {
                Text("🫵")
            }
            .phaseAnimator([false, true], trigger: fingerCount) { icon, point in
                icon
//                    .offset(y: point ? -20 : 0)
                    .scaleEffect(point ? 2 : 1)
            } animation: { point in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            
            Button {
                questionCount += 1
            } label: {
                Text("⁉️")
            }
            .phaseAnimator([false, true], trigger: questionCount) { icon, question in
                icon
//                    .offset(y: question ? -20 : 0)
                
                                    .rotationEffect(.degrees(question ? 15 : 0))
                    .scaleEffect(question ? 2 : 1)
            } animation: { question in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            
          
            
            
            
        }
        .frame(width: TILE_SIZE + 30)
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Rectangle()
            .fill(.ultraThinMaterial)
            .clipShape(Capsule())
        )
        
        
//        .cornerRadius(16)
    }
}

#Preview {
    EmojiReactionsView()
        .preferredColorScheme(.dark)
}
