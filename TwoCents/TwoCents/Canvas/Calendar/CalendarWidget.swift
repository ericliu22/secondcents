import Foundation
import SwiftUI
import Firebase

struct CalendarWidget: View {
    let widget: CanvasWidget
    @State private var earliestFoundDate: String = ""
    @State private var idsWithoutDate: [String] = []
    @State private var userColor: Color = .gray
    var spaceId: String
    private let preferredTime: String = "6:00 PM" // Set your preferred time here
    
    var body: some View {
        ZStack {
            Color(UIColor.tertiarySystemFill)
            VStack {
                Text(earliestFoundDate)
                List(idsWithoutDate, id: \.self) { id in
                    Text(id)
                }
            }
            .background(Color.white)
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .cornerRadius(CORNER_RADIUS)
        }
        .task{
            findCommonDate()
        }
    }
    
    private func findCommonDate() {
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    return
                }
                
                let data = document.data() ?? [:]
                
                var dateFrequencies: [String: Int] = [:]
                var timeFrequencies: [String: [String: Int]] = [:]
                
                // Iterate through the document data
                for (userId, userDates) in data {
                    guard let userDatesDict = userDates as? [String: [String]] else { continue }
                    
                    for (date, times) in userDatesDict {
                        dateFrequencies[date, default: 0] += 1
                        
                        if timeFrequencies[date] == nil {
                            timeFrequencies[date] = [:]
                        }
                        
                        for time in times {
                            timeFrequencies[date]?[time, default: 0] += 1
                        }
                    }
                }
                
                // Find the most common date
                let mostCommonDate = dateFrequencies.max(by: { $0.value < $1.value })?.key ?? ""
                
                // Find the most common time for that date
                guard let dateTimes = timeFrequencies[mostCommonDate] else {
                    self.earliestFoundDate = "No times available"
                    return
                }
                
                let mostCommonTimes = dateTimes.filter { $0.value == dateTimes.values.max() }
                
                // If there's a tie, find the closest time to the preferred time
                let closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes.keys))
                
                self.earliestFoundDate = "Date: \(mostCommonDate), Closest Time: \(closestTime)"
            }
    }
    
    private func findClosestTime(to preferredTime: String, from times: [String]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        guard let preferredDate = formatter.date(from: preferredTime) else {
            return ""
        }
        
        let timeDifferences = times.compactMap { time -> (String, TimeInterval)? in
            guard let date = formatter.date(from: time) else { return nil }
            return (time, abs(date.timeIntervalSince(preferredDate)))
        }
        
        return timeDifferences.min(by: { $0.1 < $1.1 })?.0 ?? ""
    }
}
