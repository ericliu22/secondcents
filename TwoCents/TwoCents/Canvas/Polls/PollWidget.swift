//
//  PollWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import UIKit
import Charts




struct PollWidget: WidgetView {
    
    
    
    private var spaceId: String
    var widget: CanvasWidget
    @State var poll: Poll?
    @State var totalVotes: Int = 0
    
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
        
        
    }
    
    func fetchPoll() {
        Task {
            //                        print("fetching")
            
            db.collection("spaces")
                .document(spaceId)
                .collection("polls")
                .document(widget.id.uuidString)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error getting document: \(error)")
                        return
                    }
                    
                    
                    do {
                        if let pollData = try snapshot?.data(as: Poll?.self) {
                            //                                                        print(pollData)
                            
                            self.poll = pollData
                            totalVotes = poll!.totalVotes()
                            //                            print("YOUR POLL IS \(self.poll)")
                            
                            // Update your SwiftUI view with the retrieved poll data.
                        } else {
                            print("Document data is empty.")
                        }
                    } catch {
                        print("Error decoding document: \(error)")
                        // Handle the decoding error, such as displaying an error message to the user.
                    }
                }
            
        }
    }
    
    
    var body: some View {
        ZStack {
            
            
            if let poll = poll {
                
                
                
                //main content
                
                
                
                
                let hasNoVotes =  poll.options.allSatisfy { $0.count == 0 }
                ZStack{
                    if hasNoVotes {
                        Chart {
                            SectorMark(
                                angle: .value("Vote", 1),
                                innerRadius: .ratio(0.618),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            .foregroundStyle(Color.gray)
                            //                                    .annotation(position: .overlay, alignment: .center) {
                            //                                                            Text("No Votes")
                            //                                                                .font(.caption)
                            //                                                                .foregroundColor(.white)
                            //                                                        }
                        }
                        
                        .padding(5)
                        .chartLegend(.hidden)
                        //                                .frame(height: 350)
                        
                        
                    } else {
                        Chart(poll.options) {option in
                            SectorMark(
                                //                                        angle: .value("Count", option.count),
                                angle: .value("Count", option.count),
                                innerRadius: .ratio(0.618),
                                angularInset: 2
                            )
                            .cornerRadius(3)
                            
                            
                            .foregroundStyle(colorForIndex(index: poll.options.firstIndex(of: option)!))
                            
                            
                        }
                        .padding(5)
                        .chartLegend(.hidden)
                        
                        
                    }
                    
                    
                    
                    VStack{
                        Text("\(totalVotes)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                        Text("Votes")
                            .font(.headline)
                            .fontWeight(.regular)
                        //                                        .fill(.ultraThickMaterial)
                            .foregroundStyle(Color.accentColor)
                        //
                        //                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
                    
                    
                    
                }
                
                
                
                .background(.regularMaterial)
                //                .background(Color.accentColor)
                
                .frame(width: TILE_SIZE, height:TILE_SIZE)
            } else {
                //                ProgressView()
                //                    .foregroundStyle(Color(UIColor.label))
                //                    .frame(width: TILE_SIZE,height: TILE_SIZE)
                //
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thinMaterial)
                    .cornerRadius(20)
                    .frame(width: TILE_SIZE,height: TILE_SIZE)
                    .onAppear {
                        
                        fetchPoll()
                        
                        
                    }
            }
        }
    }
    
  
}








func pollWidget(widget: CanvasWidget, spaceId: String) -> some View {
    return PollWidget(widget: widget, spaceId: spaceId)
    
}

//
//func colorForIndex(index: Int) -> Color {
//    // Define your color logic based on the index
//    // For example:
//    let colors: [Color] = [.red,  .orange, .green, .cyan] // Define your colors
//    return colors[index % colors.count] // Ensure index doesn't exceed the color array length
//}
//
//

struct PollWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        pollWidget(widget: CanvasWidget(id: UUID(uuidString: "B2A0B128-5877-4312-8FE4-9D66AEC76768")!, width: 150.0, height: 150.0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    }
}

