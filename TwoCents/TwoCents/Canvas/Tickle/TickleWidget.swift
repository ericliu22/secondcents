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

    private func startHapticFeedback() {
        feedbackGenerator.prepare()
        var tickleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if isPressing {
                feedbackGenerator.impactOccurred()

                tickleCount += 1
                tickleString = String(tickleCount)
            } else {
                timer.invalidate()
                tickleString = "Tickle"
            }
        }
    }

    private func stopHapticFeedback() {
        // Ensure the feedback generator can be used again if needed
        feedbackGenerator.prepare()
    }

    init(widget: CanvasWidget) {
        self.widget = widget
    }

    func ProfilePic(url: URL, targetUserColor: Color) -> some View {
        //If there is URL for profile pic, show
        //circle with stroke
        CachedUrlImage(imageUrl: url)
            .clipShape(Circle())
                .frame(width: 128, height: 128)
    }

    var body: some View {
        VStack {
            let member = canvasViewModel.members[id: widget.userId]
            if let member {
                if let profileImageUrl = member.profileImageUrl {
                    ProfilePic(
                        url: URL(string: profileImageUrl)!,
                        targetUserColor: Color.fromString(
                            name: member.userColor ?? "gray"))
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .aspectRatio(1, contentMode: .fit)
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    if let startTime =
                                        pressStartTime
                                    {
                                        let duration = Date()
                                            .timeIntervalSince(startTime)
                                        let tickleCount = Int(duration * 10)

                                        if !isPressing
                                            && tickleCount <= 1
                                        {

                                            feedbackGenerator.impactOccurred()

                                            let currentUserId =
                                                try! AuthenticationManager
                                                .shared
                                                .getAuthenticatedUser().uid
                                            //
                                            //
                                            Task {
                                                try await tickleNotification(
                                                    userId: widget.userId,
                                                    count: tickleCount)
                                            }
                                            AnalyticsManager.shared.tickle(
                                                count: tickleCount)
                                        }

                                    }

                                }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)  // Detects any drag or press
                                .onChanged { _ in
                                    if !isPressing {
                                        isPressing = true
                                        pressStartTime = Date()
                                        startHapticFeedback()
                                    }
                                }
                                .onEnded { _ in
                                    if isPressing {
                                        isPressing = false
                                        stopHapticFeedback()

                                        if let startTime =
                                            pressStartTime
                                        {
                                            let duration = Date()
                                                .timeIntervalSince(
                                                    startTime)
                                            let tickleCount = Int(
                                                duration * 10)

                                            if tickleCount > 1 {
                                                let currentUserId =
                                                    try! AuthenticationManager
                                                    .shared
                                                    .getAuthenticatedUser()
                                                    .uid
                                                Task {
                                                    try await tickleNotification(
                                                        userId:
                                                            widget.userId,
                                                        count:
                                                            tickleCount)
                                                }
                                                AnalyticsManager.shared
                                                    .tickle(
                                                        count: tickleCount)
                                            }
                                        }
                                    }

                                }
                        )

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
                        .frame(height: 50)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    TickleWidget(
        widget: CanvasWidget(
            borderColor: .black, userId: "xOEUuSr8q4UIC9Xrs14kO6gHpoD3",
            media: .tickle))
}
