//
//  EmojiCountView.swift
//  TwoCents
//
//  Created by jonathan on 4/23/24.
//

import SwiftUI



struct EmojiCountHeaderView: View {
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    private var userUID: String
    @State private var emojiCount: [String: Int]
    @State private var totalReactions: Int = 0
    
    @State private var numReactionsUsed: Int
    
    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        self.emojiCount = widget.emojis
        self._emojiCount = State(initialValue: widget.emojis)
        
        self.numReactionsUsed = 0
        
        
    }
    
    
    var body: some View {
        
        
        HStack{
            ForEach(emojiCount.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                
                if value > 0 && numReactionsUsed < 6 {
                    HStack{
                        Text("\(key)")
                        Text("\(value)")
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        totalReactions > 0
                        ? Rectangle()
                            .fill(.ultraThinMaterial)
                            .clipShape(Capsule())
                        : nil
                    )
                    .task {
                        numReactionsUsed += 1
                    }
                }
            }
            
            if numReactionsUsed >= 6 {
                HStack{
                    Text("🐐🐐🐐")
                    Text("\(totalReactions)")
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    totalReactions > 0
                    ? Rectangle()
                        .fill(.ultraThinMaterial)
                        .clipShape(Capsule())
                    : nil
                )
                
            }
            
        }
        .onAppear {
            // Calculate the total reactions when the view appears
            totalReactions = emojiCount.values.reduce(0, +)
        }
    }
}



struct EmojiCountOverlayView: View {
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    private var userUID: String
    @State private var emojiCount: [String: Int]
    @State private var totalReactions: Int = 0
    
    @State private var totalValue: Int = 0
    
    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        self.emojiCount = widget.emojis
        self._emojiCount = State(initialValue: widget.emojis)
        
    }
    
    
    
    
    var body: some View {
        
        HStack(spacing: 4){
            
            ForEach(emojiCount.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                
                
                if value > 0{
                    HStack{
                        
                        Text("\(key)")
                            .onAppear{
                                totalValue += value
                            }
                    }
                    
                    
                    .font(.caption)
                }
                
                
                
                
                
            }
            
            if totalValue > 0 {
                
                Text("\(totalValue)")
                
            }
            
            
            
            
        }
        
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        
        .background(
            totalReactions > 0
            ? Rectangle()
                .fill(.ultraThinMaterial)
                .clipShape(Capsule())
            : nil
        )
        .onAppear {
            // Calculate the total reactions when the view appears
            totalReactions = emojiCount.values.reduce(0, +)
        }
        
        
    }
    
}
//
//#Preview {
//    EmojiCountView(spaceId: <#String#>, widget: <#CanvasWidget#>)
//}
