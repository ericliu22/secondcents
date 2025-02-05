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
    @Environment(AppModel.self) var appModel
    
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    func fetchPoll() {
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
                        guard let poll = poll else {
                            return
                        }
                        totalVotes = poll.totalVotes()
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
    
    var body: some View {
        ZStack {
            if let poll = poll {
                //main content
                let hasNoVotes =  poll.options.allSatisfy { $0.count == 0 }
                //                ZStack{
                //                    if hasNoVotes {
                //                        Chart {
                //                            SectorMark(
                //                                angle: .value("Vote", 1),
                //                                innerRadius: .ratio(0.618),
                //                                angularInset: 2
                //                            )
                //                            .cornerRadius(5)
                //                            .foregroundStyle(Color.gray)
                //                            //                                    .annotation(position: .overlay, alignment: .center) {
                //                            //                                                            Text("No Votes")
                //                            //                                                                .font(.caption)
                //                            //                                                                .foregroundColor(.white)
                //                            //                                                        }
                //                        }
                //
                //                        .padding(5)
                //                        .chartLegend(.hidden)
                //                        //                                .frame(height: 350)
                //
                //
                //                    } else {
                //                        Chart(poll.options) {option in
                //                            SectorMark(
                //                                //                                        angle: .value("Count", option.count),
                //                                angle: .value("Count", option.count),
                //                                innerRadius: .ratio(0.618),
                //                                angularInset: 2
                //                            )
                //                            .cornerRadius(3)
                //
                //
                //                            .foregroundStyle(colorForIndex(index: poll.options.firstIndex(of: option)!))
                //
                //
                //                        }
                //                        .padding(5)
                //                        .chartLegend(.hidden)
                //
                //
                //                    }
                //
                //
                //
                //                    VStack{
                //                        Text("\(totalVotes)")
                //                            .font(.title)
                //                            .fontWeight(.bold)
                //                            .foregroundStyle(Color.accentColor)
                //                        Text("Votes")
                //                            .font(.headline)
                //                            .fontWeight(.regular)
                //                        //                                        .fill(.ultraThickMaterial)
                //                            .foregroundStyle(Color.accentColor)
                //                        //
                //                        //                            .padding(.bottom)
                //                    }
                //                    .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
                //
                //
                //
                //                }
                VStack{
                    if poll.options.count <= 2 {
                        
                        Text(poll.name)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .font(.title2)
                            //.font(.system(size: 22))
                            //.minimumScaleFactor(0.5)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        
                        ForEach(0..<poll.options.count) { index in
                            Button(action: {
                                guard let user = appModel.user else {
                                    return
                                }
                                self.poll!.incrementOption(index: index, userVoted: poll.votes?[user.userId], userId: user.userId)
                                totalVotes = self.poll!.totalVotes()
                                self.poll!.updatePoll(spaceId: spaceId)
                            }, label: {
                                Text(poll.options[index].name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(width: 175, alignment: .center)
                                    .font(.system(size: 20))
                                    .frame(maxWidth:.infinity)
                                    .frame(minHeight: 20, maxHeight: .infinity)
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            })
                            .buttonStyle(.bordered)
                            .tint(colorForIndex(index: index))
                            //
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                        }
                    } else {
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
                            //Fading in and out???
//                                                Text(poll.name)
//                                                    .font(.title2)
//                                                    .minimumScaleFactor(0.5)
//                                                    .fontWeight(.bold)
////                                                    .foregroundStyle(Color.accentColor)
//                                                    .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
                            if hasNoVotes {
                                FadeInOutView(mainText: poll.name)
                            } else {
                                Text(poll.name)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .font(.title2)
                                    //.minimumScaleFactor(0.5)
                                    .fontWeight(.bold)
                                    //.foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                //                .background(Color.accentColor)
                
                .frame(width: widget.width, height: widget.height)
            } else {
                //                ProgressView()
                //                    .foregroundStyle(Color(UIColor.label))
                //                    .frame(width: TILE_SIZE,height: TILE_SIZE)
                //
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thinMaterial)
                    .cornerRadius(20)
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

struct FadeInOutView: View {
    // Accept the main text as a parameter
    let mainText: String
    
    // The array of phrases
    private let phrases = ["Tell me NOW", "I'm dying to know", "lmkkkkkkk"]
    private let maxCharacters = 15
    
    // Track which text is currently shown
    @State private var currentText: String = ""
    
    // Whether the text is visible (opacity 1) or hidden (opacity 0)
    @State private var isVisible: Bool = true
    
    var body: some View {
        Text(currentText)
            .font(.title2)
            .minimumScaleFactor(0.5)
            .fontWeight(.bold)
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                startFadingLoop()
            }
    }
    
    private var truncatedMainText: String {
            guard mainText.count > maxCharacters else { return mainText }
            
            // Find the cut-off index
            let endIndex = mainText.index(mainText.startIndex, offsetBy: maxCharacters)
            
            // Take the substring up to `maxCharacters`, then append custom ellipsis
            let partial = mainText[..<endIndex]
            return partial + "...."  // Or "...", "―", etc., as you wish
    }
    
    /// Repeatedly fades out the current text, switches it, fades it back in.
    func startFadingLoop() {
        Task {
            // Initialize the text to `mainText` when the view first appears
            currentText = truncatedMainText
            
            while true {
                // 1) Fade out
                withAnimation(.easeInOut(duration: 0.5)) {
                    isVisible = false
                }
                // Wait for the fade-out to finish + a small delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // 2) Switch the text
                if currentText == truncatedMainText {
                                    // Random phrase (no need to truncate if you don't want to)
                currentText = phrases.randomElement() ?? ""
                } else {
                                    // Go back to truncated main text
                currentText = truncatedMainText
                }
                
                // 3) Fade in
                withAnimation(.easeInOut(duration: 0.5)) {
                    isVisible = true
                }
                // Wait for the fade-in to finish + a small delay
                try await Task.sleep(nanoseconds: 2_500_000_000)
            }
        }
    }
}

struct PollWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        pollWidget(widget: CanvasWidget(id: UUID(uuidString: "B2A0B128-5877-4312-8FE4-9D66AEC76768")!, width: 150.0, height: 150.0, x: 0, y: 0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    }
}

