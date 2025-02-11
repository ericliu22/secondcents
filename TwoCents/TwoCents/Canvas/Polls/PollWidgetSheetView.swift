//
//  PollWidgetSheetView.swift
//  TwoCents
//
//  Created by jonathan on 5/28/24.
//


import Foundation
import SwiftUI
import UIKit
import Charts
import FirebaseFirestore


struct PollWidgetSheetView: View {
    
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    @State var poll: Poll?
    @State var totalVotes: Int = 0
    @State var userVote: [String: Int] = [:]
    
    @Environment(AppModel.self) var appModel
    @Environment(\.dismiss) var dismissScreen
    
    
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    func fetchPoll() {
        spaceReference(spaceId: spaceId)
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
    
    
    var body: some View {
        
        //            if poll != nil {
        //                Color.green
        //
        //
        //            } else {
        //                Color.red
        //                    .onAppear {
        //                                   fetchPoll()
        //                               }
        //            }
        
        
        if poll != nil {
            
            NavigationStack{
                
                //main content
                
                
                
                let hasNoVotes =  poll!.options.allSatisfy { $0.count == 0 }
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
                        .padding(.horizontal)
                        .padding(.top)
                        .chartLegend(.hidden)
                        
                        
                        
                    } else {
                        Chart(poll!.options) {option in
                            SectorMark(
                                //                                        angle: .value("Count", option.count),
                                angle: .value("Count", option.count),
                                innerRadius: .ratio(0.618),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            
                            
                            //                                    .foregroundStyle(by: .value("Name", option.name))
                            .foregroundStyle(colorForIndex(index: poll!.options.firstIndex(of: option)!))
                            
                            //                                    .annotation(position: .overlay) {
                            //                                        Text(option.count == 0 ? "" : "\(option.count)")
                            ////
                            //                                    }
                            
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .chartLegend(.hidden)
                        
                        
                        
                        
                        //
                    }
                    
                    
                    
                    VStack{
                        Text("\(totalVotes)")
                            .font(.largeTitle   )
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Text("Votes")
                            .font(.title3)
                            .fontWeight(.regular)
                        //                                        .fill(.ultraThickMaterial)
                            .foregroundStyle(.secondary)
                    }
                    //                                .padding(.bottom)
                    
                    
                    
                }
                
                VStack{
                    HStack{
                        Text(poll!.name)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                            .minimumScaleFactor(0.5)
                            .lineLimit(0...3)
                            .multilineTextAlignment(.leading)
                        
                            .truncationMode(.tail)
                        
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    
                    
                    //                            LazyVGrid(columns:   [ GridItem(.flexible()),
                    //                                      GridItem(.flexible())], spacing: nil){
                    ForEach(0..<poll!.options.count) { index in
                        Button(action: {
                            poll!.incrementOption(index: index, userVoted: appModel.user?.userId != nil ? poll!.votes?[appModel.user!.userId] : nil, userId: appModel.user?.userId)
                            totalVotes = poll!.totalVotes()
                            poll!.updatePoll(spaceId: spaceId)
                        }, label: {
                            
                            
                            Text(poll!.options[index].name)
                                .font(.headline)
                                .frame(maxWidth:.infinity)
                                .frame(minHeight: 55, maxHeight: .infinity)
                            
                            
                            
                        })
                        
                        .buttonStyle(.bordered)
                        .tint(colorForIndex(index: index))
                        //
                        
                        .cornerRadius(10)
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                }
                //                    }
                
                
                
                
                //                .navigationTitle(poll!.name)
                //                        .navigationTitle("Poll 🤓")
                
                .toolbar{
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(action: {
                            dismissScreen()
                            
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.label))
                            //                        .font(.title2)
                            //                        .padding()
                        })
                        
                        
                    }
                }
                .navigationTitle("Poll Time 🤓")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.horizontal)
            }
            
            
        } else {
            ProgressView()
                .backgroundStyle(Color(UIColor.systemBackground) )
                .onAppear {
                    
                    fetchPoll()
                    
                    
                }
        }
        
        
        
        
        
    }
}







func colorForIndex(index: Int) -> Color {
    // Define your color logic based on the index
    // For example:
    let colors: [Color] = [.red,  .orange, .green, .cyan] // Define your colors
    return colors[index % colors.count] // Ensure index doesn't exceed the color array length
}


#Preview {
    
    
    PollWidgetSheetView(widget: CanvasWidget(id: UUID(uuidString: "B2A0B128-5877-4312-8FE4-9D66AEC76768")!, width: 150.0, height: 150.0, x: 0, y: 0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    
}


