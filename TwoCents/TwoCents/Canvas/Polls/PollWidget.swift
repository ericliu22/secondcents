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
        fetchPoll()
        listenToPoll()
    }
    
    init(widget: CanvasWidget, spaceId: String, poll: Poll) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
        self.poll = poll
    }
    
    func listenToPoll() {
        db.collection("spaces")
            .document(spaceId)
            .collection("polls")
            .document(widget.id.uuidString)
            .addSnapshotListener { document , error in
                guard let document else {return}
                do {
                    let newPoll = try document.data(as: Poll.self)
                    withAnimation{
                        poll?.options = newPoll.options
                        poll?.name = newPoll.name
                        poll?.uploadPoll(spaceId: spaceId)
                    }
                } catch {
                    print("Failed to Fetch Poll")
                }
            }
    }
    
    func fetchPoll() {
        Task {
            self.poll = try! await db.collection("spaces")
                .document(spaceId)
                .collection("polls")
                .document(widget.id.uuidString)
                .getDocument(as: Poll.self)
        }
    }
    
    var body: some View {
        VStack{
            Text("poll")
        }
        .frame(width: widget.width, height: widget.height)
        .onTapGesture{isShowingPoll.toggle()}
        .fullScreenCover(isPresented: $isShowingPoll, content: {
            if (poll != nil) {
                ZStack{
                    ZStack(alignment: .topLeading) {
                        Color.white.edgesIgnoringSafeArea(.all)
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.largeTitle)
                                .padding(20)
                        })
                        VStack{
                            Text(poll!.name)
                                .padding(.top, 10)
                            Section{
                                VStack{
                                    //Text("Idk how to change chart colors lmao").foregroundColor(.black)
                                    Chart{
                                        ForEach(poll!.options) {option in
                                            SectorMark(
                                                angle: .value("Count", option.count),
                                                innerRadius: .ratio(0.618),
                                                angularInset: 1.5
                                            )
                                            .cornerRadius(5)
                                            .foregroundStyle(by: .value("Name", option.name))
                                        }
                                    }
                                    .padding()
                                }
                            }
                            Section("Vote") {
                                //Some warning about non-constant range but yolo
                                ForEach(0..<poll!.options.count) { index in
                                    Button(action: {
                                        poll!.incrementOption(index: index)
                                    }, label: {
                                        HStack{
                                            Text(poll!.options[index].name)
                                                .foregroundColor(.black)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }.draggable(widget)
            } else {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint:
                                .primary)
                    )
                    .background(.thickMaterial)
            }
        })
    }
}

func pollWidget(widget: CanvasWidget, spaceId: String) -> AnyView {
    return AnyView(PollWidget(widget: widget, spaceId: spaceId))
}
