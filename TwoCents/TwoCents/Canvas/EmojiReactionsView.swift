//
//  EmotionalReactions.swift

import SwiftUI

struct EmojiReactionsView: View {
    
    @State private var emojiPressed: [String: Bool] = [
        "❤️":false,
        "👍":false,
        "👎":false,
        "😭":false,
        "🫵":false,
        "⁉️":false
    ]
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    private var userUID: String
    
    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
    }
    
    private func addEmoji(emoji: String) {
        db.collection("spaces")
            .document(spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
    }
    
    private func removeEmoji() {
        
    }
    
    let inboundBubbleColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    let reactionsBGColor = Color(#colorLiteral(red: 0.05490196078, green: 0.09019607843, blue: 0.137254902, alpha: 1))
    var body: some View {
        HStack(spacing: 10) {
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    emojiPressed["❤️"]!.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
                        emojiPressed["❤️"] = false
                    }
                }
            } label: {
                ZStack {
                    SplashView()
                        .opacity(emojiPressed["❤️"]! ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: emojiPressed["❤️"])
                        .scaleEffect(emojiPressed["❤️"]! ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: emojiPressed["❤️"])
                    
                    SplashView()
                        .rotationEffect(.degrees(90))
                        .opacity(emojiPressed["❤️"]! ? 0 : 1)
                        .offset(y: emojiPressed["❤️"]! ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: emojiPressed["❤️"])
                        .scaleEffect(emojiPressed["❤️"]! ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: emojiPressed["❤️"])
                    
                   Text("❤️")
                        .phaseAnimator([false, true], trigger: emojiPressed["❤️"]) { icon, scaleFromBottom in
                            icon
                                .scaleEffect(scaleFromBottom ? 1.5 : 1, anchor: .bottom)
                        } animation: { scaleFromBottom in
                                .bouncy(duration: 0.4, extraBounce: 0.4)
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: emojiPressed["❤️"]! ? 0 : 4)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: emojiPressed["❤️"])
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(.systemPink))
                                .hueRotation(.degrees(emojiPressed["❤️"]! ? 300 : 200))
                                .scaleEffect(emojiPressed["❤️"]! ? 1.15 : 0)
                                .animation(.easeInOut(duration: 0.5), value: emojiPressed["❤️"])
                        )
                        
                }
            }
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    emojiPressed["👍"]!.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
                        emojiPressed["👍"] = false
                    }
                }
            } label: {
                ZStack {
                  
                    SplashView()
                        .opacity(emojiPressed["👍"]! ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: emojiPressed["👍"])
                        .scaleEffect(emojiPressed["👍"]! ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: emojiPressed["👍"])
                    
                    SplashView()
                        .rotationEffect(.degrees(90))
                        .opacity(emojiPressed["👍"]! ? 0 : 1)
                        .offset(y: emojiPressed["👍"]! ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: emojiPressed["👍"])
                        .scaleEffect(emojiPressed["👍"]! ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: emojiPressed["👍"])
                    Text("👍")
                        .phaseAnimator([false, true], trigger: emojiPressed["👍"]) { icon, scaleRotate in
                            icon
                                .rotationEffect(.degrees(scaleRotate ? -5 : 0), anchor: .bottomLeading)
                                .scaleEffect(scaleRotate ? 1.5 : 1)
                        } animation: { scaleRotate in
                                .bouncy(duration: 0.4, extraBounce: 0.4)
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: emojiPressed["👍"]! ? 0 : 4)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: emojiPressed["👍"])
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(.systemPink))
                                .hueRotation(.degrees(emojiPressed["👍"]! ? 300 : 200))
                                .scaleEffect(emojiPressed["👍"]! ? 1.15 : 0)
                                .animation(.easeInOut(duration: 0.5), value: emojiPressed["👍"])
                            
                        )
                }
                
            }
            
            Button {
                
            } label: {
                Text("👎")
            }
            .phaseAnimator([false, true], trigger: emojiPressed["👎"]) { icon, dislike in
                icon
                    .rotationEffect(.degrees(dislike ? -45 : 0), anchor: .leading)
                    .scaleEffect(dislike ? 1.5 : 1)
            } animation: { dislike in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            Button {

            } label: {
                Text("😭")
            }
            .phaseAnimator([false, true], trigger: emojiPressed["😭"]) { icon, crying in
                icon
                    .offset(y: crying ? -20 : 0)
                    .scaleEffect(crying ? 1.5 : 1)
            } animation: { crying in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            Button {
                
            } label: {
                Text("🫵")
            }
            .phaseAnimator([false, true], trigger: emojiPressed["🫵"]) { icon, point in
                icon
//                    .offset(y: point ? -20 : 0)
                    .scaleEffect(point ? 2 : 1)
            } animation: { point in
                    .bouncy(duration: 0.2, extraBounce: 0.4)
            }
            
            
            Button {
                
            } label: {
                Text("⁉️")
            }
            .phaseAnimator([false, true], trigger: emojiPressed["⁉️"]) { icon, question in
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
/*
#Preview {
    EmojiReactionsView()
        .preferredColorScheme(.dark)
}
*/
