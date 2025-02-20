//
//  TickleWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/4.
//
import SwiftUI

struct TickleWidget: WidgetView {
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    let widget: CanvasWidget
    @State var pressStartTime: Date?
    @State var isPressing: Bool = false
    @State var tickleString = "Tickle"

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    init(widget: CanvasWidget) {
        self.widget = widget
    }

    func ProfilePic(url: URL) -> some View {
        //If there is URL for profile pic, show
        //circle with stroke
        CachedImage(imageUrl: url)
            .clipShape(Circle())
                .frame(width: 100, height: 100)
    }

    var body: some View {
        VStack {
            let member = canvasViewModel.members[id: widget.userId]
            if let member {
                if let profileImageUrl = member.profileImageUrl {
                    ProfilePic(
                        url: URL(string: profileImageUrl)!)
                } else {
                    Circle()
                        .fill(
                         Color.fromString(
                            name: member.userColor ?? "gray")
                        )
                        .frame(width: 100, height: 100)
                }
                Button {
                    feedbackGenerator.impactOccurred()
                    Task {
                        try await tickleNotification(
                            userId: widget.userId,
                            count: 1)
                    }
                    guard let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
                        return
                    }
                    AnalyticsManager.tickle(userId: userId, targetUserId: widget.userId,
                        count: 1)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thinMaterial)
                            .aspectRatio(1, contentMode: .fit)
                        Text(tickleString)
                            .font(
                                tickleString == "Tickle"
                                ? .title2 : .largeTitle
                            )
                            .fontWeight(.bold)
                            .fontDesign(
                                tickleString == "Tickle"
                                ? .default : .monospaced
                            )
                            .foregroundStyle(.secondary)
                            .frame(width: .infinity, height: 50)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThickMaterial)
    }
}

#Preview {
    TickleWidget(
        widget: CanvasWidget(
            borderColor: .black, userId: "xOEUuSr8q4UIC9Xrs14kO6gHpoD3",
            media: .tickle))
}
