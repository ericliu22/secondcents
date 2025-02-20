import SwiftUI
import UIKit

// MARK: - Event Model
struct Event: Identifiable {
    let id = UUID()
    var start: CGFloat  // Start time in points from the top (e.g. minutes from midnight)
    var end: CGFloat    // End time in points from the top
}

// MARK: - SwiftUI Timeline Content
/// Displays a 24‑hour timeline (without scrolling) that draws hour lines, labels,
/// and green blocks for each event in the events array.
struct TimelineContent: View {
    private let hourHeight: CGFloat = 60
    private let dayHeight: CGFloat = 24 * 60
    @Binding var events: [Event]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Draw 25 horizontal hour lines with labels.
            ForEach(0..<25, id: \.self) { hour in
                let yPos = CGFloat(hour) * hourHeight
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .position(x: UIScreen.main.bounds.width / 2, y: yPos)
                Text(formattedHour(for: hour))
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(width: 50, alignment: .trailing)
                    .position(x: 25, y: yPos)
            }
            // Vertical divider after the labels.
            Rectangle()
                .fill(Color.gray)
                .frame(width: 1, height: dayHeight)
                .position(x: 50, y: dayHeight / 2)
            
            // Draw a block for each event.
            ForEach(events) { event in
                Rectangle()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: UIScreen.main.bounds.width - 60, height: event.end - event.start)
                    .position(
                        x: (UIScreen.main.bounds.width - 60) / 2 + 60,
                        y: event.start + (event.end - event.start) / 2
                    )
            }
        }
        .frame(height: dayHeight)
        .background(Color.black)
    }
    
    private func formattedHour(for hour: Int) -> String {
        if hour == 0 { return "12 AM" }
        else if hour < 12 { return "\(hour) AM" }
        else if hour == 12 { return "12 PM" }
        else { return "\(hour - 12) PM" }
    }
}

// MARK: - UIScrollView Wrapper
/// A UIViewRepresentable that embeds a UIScrollView containing the TimelineContent.
struct TimelineScrollView: UIViewRepresentable {
    @Binding var events: [Event]
    var onLongPress: ((CGFloat) -> Void)?
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        // Set content size to accommodate the 24‑hour timeline.
        let contentHeight = 24 * 60  // 1440 points
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(contentHeight))
        
        // Create the SwiftUI TimelineContent view.
        let hostingController = UIHostingController(rootView: TimelineContent(events: $events))
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add a long press gesture recognizer.
        let longPress = UILongPressGestureRecognizer(target: context.coordinator,
                                                     action: #selector(context.coordinator.handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        // Let scrolling work smoothly.
        longPress.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(longPress)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // No update required in this example.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onLongPress: onLongPress)
    }
    
    class Coordinator: NSObject {
        var onLongPress: ((CGFloat) -> Void)?
        
        init(onLongPress: ((CGFloat) -> Void)?) {
            self.onLongPress = onLongPress
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                let location = gesture.location(in: gesture.view)
                print("Long press at y: \(location.y)")
                // Snap the Y coordinate to the nearest hour (60 points per hour).
                let alignedY = floor(location.y / 60) * 60
                onLongPress?(alignedY)
            }
        }
    }
}

// MARK: - Main AvailabilityTimePicker View
struct AvailabilityTimePicker: View {
    // Tracks all events with their start and end times (in points).
    @State private var events: [Event] = []
    
    private let defaultDuration: CGFloat = 60  // Default event duration of 1 hour.
    
    var body: some View {
        ZStack {
            TimelineScrollView(events: $events, onLongPress: { y in
                // Check if the long press location is within an existing event.
                if !events.contains(where: { $0.start <= y && y < $0.end }) {
                    let newEvent = Event(start: y, end: y + defaultDuration)
                    events.append(newEvent)
                }
            })
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Preview
struct AvailabilityTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        AvailabilityTimePicker()
    }
}

