//
//  EmotionalReactions.swift

import SwiftUI
import FirebaseFirestore

struct EmojiReactionsView: View {
    
    private var userPressed: [String: Bool] = [
        "❤️":false,
        "👍":false,
        "👎":false,
        "😭":false,
        "🫵":false,
        "⁉️":false
    ]
    @State private var emojiCount: [String: Int]
    @Environment(AppModel.self) var appModel
    private var spaceId: String
    private var widget: CanvasWidget
    private var userUID: String
    
    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        self.emojiCount = widget.emojis
        self.userPressed = checkUser(emojiPressed: widget.emojiPressed)
    }
    
    private func checkUser(emojiPressed: [String: [String]]) -> [String: Bool]{
        var pressedValues: [String: Bool] = [:]
        var pressed: Bool
        
        for (emoji, users) in emojiPressed {
            pressed = false
            for user in users {
                if (userUID == user) {
                    pressed = true
                    break
                }
            }
            pressedValues[emoji] = pressed
        }
        return pressedValues
    }
    
    private func updateEmoji(emoji: String) {
        guard let pressed = userPressed[emoji] else {
            return
        }
        if !pressed {
            addEmoji(emoji: emoji)
        } else {
            removeEmoji(emoji: emoji)
        }
    }
    
    private func emojiNotification(emoji: String) -> String {
        switch emoji {
        case "❤️":
            return "loved ❤️"
        case "👍":
            return "liked 👍"
        case "👎":
            return "hated 👎"
        case "😭":
            return "cried at 😭"
        case "🫵":
            return "SHAMED 🫵"
        case "⁉️":
            return "AYO'd ⁉️"
        default:
            return "reacted"
        }
    }
    
    private func addEmoji(emoji: String) {
        emojiCount[emoji]! += 1
        
        spaceReference(spaceId: spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .updateData([
                "emojis": emojiCount,
                "emojiPressed.\(emoji)": FieldValue.arrayUnion([userUID])
            ])
        Task {
            guard let username = appModel.user?.name else {
                print("Failed to get username")
                return
            }
            let body = "\(username) \(emojiNotification(emoji: emoji))"
            try await reactionNotification(spaceId: spaceId, body: body, widgetId: widget.id.uuidString)
        }
    }
    
    private func removeEmoji(emoji: String) {
        emojiCount[emoji]! -= 1
        
        spaceReference(spaceId: spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .updateData([
                "emojis": emojiCount,
                "emojiPressed.\(emoji)": FieldValue.arrayRemove([userUID])
            ])
    }
    
    let inboundBubbleColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    let reactionsBGColor = Color(#colorLiteral(red: 0.05490196078, green: 0.09019607843, blue: 0.137254902, alpha: 1))
    var body: some View {
        HStack(spacing: 10) {
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "❤️")
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                ZStack {
                    SplashView(userColor: Color.accentColor)
                        .opacity(userPressed["❤️"]! ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: userPressed["❤️"])
                        .scaleEffect(userPressed["❤️"]! ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: userPressed["❤️"])
                    
                    SplashView(userColor: Color.accentColor)
                        .rotationEffect(.degrees(90))
                        .opacity(userPressed["❤️"]! ? 0 : 1)
                        .offset(y: userPressed["❤️"]! ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: userPressed["❤️"])
                        .scaleEffect(userPressed["❤️"]! ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: userPressed["❤️"])
                    
                   Text("❤️")
                        .font(.title3)
                        .phaseAnimator([false, true], trigger: userPressed["❤️"]) { icon, scaleFromBottom in
                            icon
                            
                                .scaleEffect(scaleFromBottom ? 1.5 : 1, anchor: .bottom)
                        } animation: { scaleFromBottom in
                            if userPressed["❤️"]! {
                                       return .bouncy(duration: 0.4, extraBounce: 0.4)
                                   } else {
                                       return .none // No animation when userPressed is false
                                   }
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: userPressed["❤️"]! ? 4 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: userPressed["❤️"])
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color.accentColor)
                                .hueRotation(.degrees(userPressed["❤️"]! ? -10 : 10))
                                .scaleEffect(userPressed["❤️"]! ? 0 : 1.15)
                                .animation(.easeInOut(duration: 0.5), value: userPressed["❤️"])
                        )
                        
                        .background(
                            userPressed["❤️"]!
                            ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                                .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                                .frame(width: 30, height: 30)
                                .animation(.easeInOut(duration: 0.5),value: userPressed["❤️"])
                            
                            : nil)
                        
                }
            }
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "👍")
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                ZStack {
                  
                    SplashView(userColor: Color.accentColor)
                        .opacity(userPressed["👍"]! ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5).delay(0.25), value: userPressed["👍"])
                        .scaleEffect(userPressed["👍"]! ? 1.25 : 0)
                        .animation(.easeInOut(duration: 0.5), value: userPressed["👍"])
                    
                    SplashView(userColor: Color.accentColor)
                        .rotationEffect(.degrees(90))
                        .opacity(userPressed["👍"]! ? 0 : 1)
                        .offset(y: userPressed["👍"]! ? 6 : -6)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: userPressed["👍"])
                        .scaleEffect(userPressed["👍"]! ? 1.25 : 0)
                        .animation(.easeOut(duration: 0.5), value: userPressed["👍"])
                    Text("👍")
                        .font(.title3)
                        .phaseAnimator([false, true], trigger: userPressed["👍"]) { icon, scaleRotate in
                            icon
                                .rotationEffect(.degrees(scaleRotate ? -5 : 0), anchor: .bottomLeading)
                                .scaleEffect(scaleRotate ? 1.5 : 1)
                        } animation: { scaleRotate in
                            
                            
                            if userPressed["👍"]! {
                                       return .bouncy(duration: 0.4, extraBounce: 0.4)
                                   } else {
                                       return .none // No animation when userPressed is false
                                   }
                        }
                        .background(
                            Circle()
                                .strokeBorder(lineWidth: userPressed["👍"]! ? 4 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.1),value: userPressed["👍"])
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color.accentColor)
                                .hueRotation(.degrees(userPressed["👍"]! ? -10 : 10))
                                .scaleEffect(userPressed["👍"]! ? 0 : 1.15)
                                .animation(.easeInOut(duration: 0.5), value: userPressed["👍"])
                            
                        )
                        .background(
                            userPressed["👍"]!
                            ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                                .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                                .frame(width: 30, height: 30)
                                .animation(.easeInOut(duration: 0.5),value: userPressed["👍"])
                            
                            : nil)
                    
                }
                
            }
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "👎")
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                Text("👎")
                    .font(.title3)
            }
            .phaseAnimator([false, true], trigger: userPressed["👎"]) { icon, dislike in
                icon
                    .rotationEffect(.degrees(dislike ? -45 : 0), anchor: .leading)
                    .scaleEffect(dislike ? 1.5 : 1)
            } animation: { dislike in
                if userPressed["👎"]! {
                    return  .bouncy(duration: 0.4, extraBounce: 0.4)
                       } else {
                           return .none // No animation when userPressed is false
                       }
                   
            }
            .background(
                userPressed["👎"]!
                ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                    .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                    .frame(width: 30, height: 30)
                    .animation(.easeInOut(duration: 0.5),value: userPressed["👎"])
                
                : nil)
            
            
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "😭")
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                Text("😭")
                    .font(.title3)
            }
            .phaseAnimator([false, true], trigger: userPressed["😭"]) { icon, crying in
                icon
                    .offset(y: crying ? -20 : 0)
                    .scaleEffect(crying ? 1.5 : 1)
            } animation: { crying in
                 
                
                if userPressed["😭"]! {
                           return     .bouncy(duration: 0.4, extraBounce: 0.4)
                       } else {
                           return .none // No animation when userPressed is false
                       }
            }
            .background(
                userPressed["😭"]!
                ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                    .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                    .frame(width: 30, height: 30)
                    .animation(.easeInOut(duration: 0.5).delay(0.1),value: userPressed["😭"])
                
                : nil)
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "🫵")
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                Text("🫵")
                    .font(.title3)
            }
            .phaseAnimator([false, true], trigger: userPressed["🫵"]) { icon, point in
                icon
//                    .offset(y: point ? -20 : 0)
                    .scaleEffect(point ? 2 : 1)
            } animation: { point in
                  
                if userPressed["🫵"]! {
                           return     .bouncy(duration: 0.4, extraBounce: 0.4)
                       } else {
                           return .none // No animation when userPressed is false
                       }
            }
            .background(
                userPressed["🫵"]!
                ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                    .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                    .frame(width: 30, height: 30)
                    .animation(.easeInOut(duration: 0.5),value: userPressed["🫵"])
                
                : nil)
            
            
            Button {
                
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 5)) {
                    updateEmoji(emoji: "⁉️")
                }
                
                // Trigger haptic feedback multiple times
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
            } label: {
                Text("⁉️")
                    .font(.title3)
            }
            .phaseAnimator([false, true], trigger: userPressed["⁉️"]) { icon, question in
                icon
//                    .offset(y: question ? -20 : 0)
                
                    .rotationEffect(.degrees(question ? 15 : 0))
                    .scaleEffect(question ? 2 : 1)
            } animation: { question in
                
                if userPressed["⁉️"]! {
                           return     .bouncy(duration: 0.4, extraBounce: 0.4)
                       } else {
                           return .none // No animation when userPressed is false
                       }
                    
            }
            .background(
                userPressed["⁉️"]!
                ? Circle()
//                                .frame(width: 50, height: 50)
//                                .fill(Color.accentColor)
                    .fill(Color(UIColor.systemFill))
//                                .fill(.thickMaterial)
                    .frame(width: 30, height: 30)
                    .animation(.easeInOut(duration: 0.5),value: userPressed["⁉️"])
                
                : nil)
            
            
          
            
            
            
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
