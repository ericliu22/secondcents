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
    
    @State private var   allAboveZero : Bool
    
    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        self.emojiCount = widget.emojis
        self._emojiCount = State(initialValue: widget.emojis)
        
        self.allAboveZero = false
        
        
    }
    
    
    var body: some View {
        
        
        HStack{
           
            
            if allAboveZero{
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
                
            } else {
                
                ForEach(emojiCount.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                    
                    if value > 0 {
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
                        
                    }
                }
                
                
                
                
            }
             
            
            
        }
        .onAppear {
            
            // Calculate the total reactions when the view appears
            totalReactions = emojiCount.values.reduce(0, +)
            
            
            allAboveZero = emojiCount.values.allSatisfy { $0 > 0 }

          

        }
    }
}



struct EmojiCountOverlayView: View {
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    private var userUID: String
    @State private var emojiCount: [String: Int]
    @State private var totalReactions: Int = 0
    
//    @State private var totalValue: Int = 0
    
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
                    }
                    
                    .font(.caption)
                }
                
            }
            
            if totalReactions > 0 {
                
                Text("\(totalReactions)")
                    .font(.caption)
                
            }
            
        }
        
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        
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
