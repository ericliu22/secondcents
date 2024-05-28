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



struct PollWidget: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private var spaceId: String
    private var widget: CanvasWidget
    @State var poll: Poll?
    @State var isShowingPoll: Bool = false

    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
//        fetchPoll()
//        listenToPoll()
        
    }
    
//    init(widget: CanvasWidget, spaceId: String, poll: Poll) {
//        assert(widget.media == .poll)
//        self.widget = widget
//        self.spaceId = spaceId
//        print("1", poll)
//        print("2",self.poll as Any)
//        self.poll = poll
//        print("SELF.POLL: \(self.poll!)")
//    }
////    
//    func listenToPoll() {
//        db.collection("spaces")
//            .document(spaceId)
//            .collection("polls")
//            .document(widget.id.uuidString)
//            .addSnapshotListener { document , error in
//                guard let document else {return}
//                do {
//                    let newPoll = try document.data(as: Poll.self)
//                    withAnimation{
//                        poll?.options = newPoll.options
//                        poll?.name = newPoll.name
//                        poll?.uploadPoll(spaceId: spaceId)
//                    }
//                } catch {
//                    print("Failed to Fetch Poll")
//                }
//            }
//    }
//    
//    
    
    
    
    func fetchPoll() {
        Task {
//            print("fetching")
            //
            //            do {
            //                self.poll = try await db.collection("spaces")
            //                                        .document(spaceId)
            //                                        .collection("polls")
            //                                        .document(widget.id.uuidString)
            //
            //                                        .getDocument(as: Poll.self)
            //                print("DONE")
            //            } catch {
            //                print("Error fetching poll document: \(error)")
            //            }
            
            db.collection("spaces")
                .document(spaceId)
                .collection("polls")
                .document(widget.id.uuidString)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error getting document: \(error)")
                        return
                    }
                    
//                    guard let document = document, document.exists else {
//                        print("Document does not exist")
//                        return
//                    }
                    
                    do {
                        if let pollData = try snapshot?.data(as: Poll?.self) {
//                            print(pollData)
                        
                           self.poll = pollData
                            print("THIS PART \(self.poll)")
                                           
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
        ZStack{
            
            Color.blue
                .onTapGesture{
                    isShowingPoll.toggle()
                    print("tapped")
                }
            //Poll widgets must have a name lest they crash
            Text(widget.widgetName!)
            
            
            
            
        }
        
        .frame(width: widget.width, height: widget.height)
       
        .fullScreenCover(isPresented: $isShowingPoll, content: {
            if poll != nil {
                Color.green
                 
                
            } else {
                Color.red
                    .onAppear {
                                   fetchPoll()
                               }
            }
            
            
//            if (poll != nil) {
//                ZStack{
//                    ZStack(alignment: .topLeading) {
//                        Color.white.edgesIgnoringSafeArea(.all)
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }, label: {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.black)
//                                .font(.largeTitle)
//                                .padding(20)
//                        })
//                        VStack{
//                            Text(poll!.name)
//                                .padding(.top, 10)
//                            Section{
//                                VStack{
//                                    //Text("Idk how to change chart colors lmao").foregroundColor(.black)
//                                    Chart(poll!.options) {option in
//                                        SectorMark(
//                                            angle: .value("Count", option.count),
//                                            innerRadius: .ratio(0.618),
//                                            angularInset: 1.5
//                                        )
//                                        .cornerRadius(5)
//                                        .foregroundStyle(by: .value("Name", option.name))
//                                    }
//                                    .padding()
//                                    
//                                }
//                                Section("Vote") {
//                                    //Some warning about non-constant range but yolo
//                                    ForEach(0..<poll!.options.count) { index in
//                                        Button(action: {
//                                            poll!.incrementOption(index: index)
//                                        }, label: {
//                                            HStack{
//                                                Text(poll!.options[index].name)
//                                                    .foregroundColor(.black)
//                                            }
//                                        })
//                                    }
//                                }
//                            }
//                        }
//                    }.draggable(widget)
//                    
//                }
//            }
        })
    }
}

func pollWidget(widget: CanvasWidget, spaceId: String) -> AnyView {
    return AnyView(PollWidget(widget: widget, spaceId: spaceId))
    
//    return AnyView(Color.red)
//    return AnyView(PollWidget(widget: <#T##CanvasWidget#>, spaceId: <#T##String#>))
}




struct PollWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        pollWidget(widget: CanvasWidget(id: UUID(uuidString: "03FC19D8-BA51-4EE3-B012-BED5AA075ACC")!, width: 150.0, height: 150.0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    }
}

