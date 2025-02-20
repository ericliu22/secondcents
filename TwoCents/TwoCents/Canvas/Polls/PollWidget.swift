//
//  PollWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import SwiftUI
import FirebaseFirestore
import Charts
import UIKit

// MARK: - PollViewModel
class PollViewModel: ObservableObject {
    @Published var poll: Poll?
    @Published var totalVotes: Int = 0
    private var pollListener: ListenerRegistration?
    private let widgetId: String
    private let spaceId: String

    init(widgetId: String, spaceId: String) {
        self.widgetId = widgetId
        self.spaceId = spaceId
        fetchPoll()
    }
    
    func fetchPoll() {
        pollListener = spaceReference(spaceId: spaceId)
            .collection("polls")
            .document(widgetId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                do {
                    // Use Poll.self to avoid a double-optional.
                    if let pollData = try snapshot?.data(as: Poll.self) {
                        DispatchQueue.main.async {
                            self.poll = pollData
                            self.totalVotes = pollData.totalVotes()
                        }
                    } else {
                        print("Document data is empty.")
                    }
                } catch {
                    print("Error decoding document: \(error)")
                }
            }
    }
    
    // MVVM-friendly method that mutates the poll.
    func incrementOption(at index: Int, for userId: String) {
        guard var currentPoll = poll else { return }
        
        currentPoll.incrementOption(
            index: index,
            userVoted: currentPoll.votes?[userId],
            userId: userId
        )
        totalVotes = currentPoll.totalVotes()
        currentPoll.updatePoll(spaceId: spaceId)
        poll = currentPoll
    }
    
    deinit {
        pollListener?.remove()
    }
}

// MARK: - PollWidget
struct PollWidget: WidgetView {
    private var spaceId: String
    var widget: CanvasWidget
    @Environment(AppModel.self) var appModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    // Use a view model instead of local state for poll data.
    @StateObject private var viewModel: PollViewModel

    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
        
        // Initialize the view model with the widget id and space id.
        _viewModel = StateObject(wrappedValue: PollViewModel(widgetId: widget.id.uuidString, spaceId: spaceId))
    }
    
    var body: some View {
        ZStack {
            if let poll = viewModel.poll {
                let hasNoVotes = poll.options.allSatisfy { $0.count == 0 }
                
                VStack {
                    if poll.options.count <= 2 {
                        Text(poll.name)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        
                        ForEach(0..<poll.options.count, id: \.self) { index in
                            Button(action: {
                                guard let user = appModel.user else { return }
                                // Call the view model's method to handle the mutation.
                                viewModel.incrementOption(at: index, for: user.userId)
                            }, label: {
                                Text(poll.options[index].name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(width: 175, alignment: .center)
                                    .font(.system(size: 20))
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 20, maxHeight: .infinity)
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            })
                            .buttonStyle(.bordered)
                            .tint(colorForIndex(index: index))
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                        }
                    } else {
                        ZStack {
                            if hasNoVotes {
                                Chart {
                                    SectorMark(
                                        angle: .value("Vote", 1),
                                        innerRadius: .ratio(0.618),
                                        angularInset: 2
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(Color.gray)
                                }
                                .padding(5)
                                .chartLegend(.hidden)
                            } else {
                                Chart(poll.options) { option in
                                    SectorMark(
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
                            if hasNoVotes {
                                Text(poll.name)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(EdgeInsets(top: 60, leading: 80, bottom: 60, trailing: 80))
                            } else {
                                Text(poll.name)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(EdgeInsets(top: 60, leading: 80, bottom: 60, trailing: 80))
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .frame(width: widget.width, height: widget.height)
                .onTapGesture {
                    canvasViewModel.activeWidget = widget
                    canvasViewModel.activeSheet = .poll
                }
            } else {
                // Loading state
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thinMaterial)
                    .cornerRadius(20)
            }
        }
    }
}






func pollWidget(widget: CanvasWidget, spaceId: String) -> some View {
    return PollWidget(widget: widget, spaceId: spaceId)
}

//struct PollWidget_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        pollWidget(widget: CanvasWidget(id: UUID(uuidString: "B2A0B128-5877-4312-8FE4-9D66AEC76768")!, width: 150.0, height: 150.0, x: 0, y: 0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
//    }
//}

