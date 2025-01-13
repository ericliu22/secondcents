//
//  EmotionalReactions.swift

import SwiftUI
import FirebaseFirestore

struct EmojiReactionContextView: View {
    
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
    
    @Binding var refreshId: UUID
    
    init(spaceId: String, widget: CanvasWidget, refreshId: Binding<UUID>) {
        self._refreshId = refreshId
        
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
    
    func updateEmoji(emoji: String) {
        if !userPressed[emoji]! {
            addEmoji(emoji: emoji)
        } else {
            removeEmoji(emoji: emoji)
        }
    }
    
    private func emojiNotification(emoji: String) -> String {
        switch emoji {
        case "❤️":
            return "❤️loved"
        case "👍":
            return "👍liked"
        case "👎":
            return "👎hated"
        case "😭":
            return "😭cried at"
        case "🫵":
            return "🫵SHAMED"
        case "⁉️":
            return "⁉️AYO'd"
        default:
            return "reacted"
        }
    }
    
    private func addEmoji(emoji: String) {
        emojiCount[emoji]! += 1
        
        db.collection("spaces")
            .document(spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .updateData([
                "emojis": emojiCount,
                "emojiPressed.\(emoji)": FieldValue.arrayUnion([userUID])
            ]) { error in
                if error == nil {
                    Task {
                        guard let username = appModel.user?.name else {
                            print("Failed to get username")
                            return
                        }
                        let body = "\(username) \(emojiNotification(emoji: emoji))"
                        
                        try await reactionNotification(spaceId: spaceId, body: body, widgetId: widget.id.uuidString)
                        refreshId = UUID() // Only refresh when the update is successful
                    }
                } else {
                    print("Failed to add emoji: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }

    private func removeEmoji(emoji: String) {
        emojiCount[emoji]! -= 1
        
        db.collection("spaces")
            .document(spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .updateData([
                "emojis": emojiCount,
                "emojiPressed.\(emoji)": FieldValue.arrayRemove([userUID])
            ]) { error in
                if error == nil {
                    refreshId = UUID() // Only refresh when the update is successful
                } else {
                    print("Failed to remove emoji: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }
    
    let inboundBubbleColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    let reactionsBGColor = Color(#colorLiteral(red: 0.05490196078, green: 0.09019607843, blue: 0.137254902, alpha: 1))
    var body: some View {
//        HStack(spacing: 10) {
        
        ControlGroup{
            Button {
                
                
                updateEmoji(emoji: "❤️")
                
                
            } label: {
                
                Text("❤️")
                
                
                
            }
            
            Button {
                
                updateEmoji(emoji: "👍")
                
                
            } label: {
                
                Text("👍")
                
                
            }
            
            Button {
                
                
                updateEmoji(emoji: "👎")
                
                
                
            } label: {
                Text("👎")
                
            }
            
        }
        
        ControlGroup{
            
            Button {
                updateEmoji(emoji: "😭")
                
            } label: {
                Text("😭")
                
            }
            
            
            Button {
                
                updateEmoji(emoji: "🫵")
                
                
            } label: {
                Text("🫵")
                
            }
            
            Button {
                
                
                updateEmoji(emoji: "⁉️")
                
            } label: {
                Text("⁉️")
                
            }
            
        }
//        .cornerRadius(16)
    }
}
/*
#Preview {
    EmojiReactionsView()
        .preferredColorScheme(.dark)
}
*/



