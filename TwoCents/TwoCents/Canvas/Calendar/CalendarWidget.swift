import Foundation
import SwiftUI
import Firebase

struct CalendarWidget: View {
    let widget: CanvasWidget
    @State private var earliestFoundDate: String = ""
    @State private var idsWithoutDate: [String] = []
    @State private var userColor: Color = .gray
    var spaceId: String
    private let preferredTime: String = "7:00 PM" // Set your preferred time here
    
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
        .task {
            await setupSnapshotListener()
        }
    }
    
    private func setupSnapshotListener() async {
        let db = Firestore.firestore()
        
        // Safely unwrap user ID
        guard let uid = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
            print("Error: User not authenticated")
            return
        }

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("Document does not exist")
                    return
                }

                let data = document.data() ?? [:]
                print("Fetched data: \(data)")
                
                // Get preferred time from document data
                let preferredTime = data["preferredTime"] as? String ?? self.preferredTime
                print("Preferred Time: \(preferredTime)")

                var dateFrequencies: [String: Int] = [:]
                var timeFrequencies: [String: [String: Int]] = [:]

                // Iterate through the document data
                for (userId, userDates) in data where userId != "preferredTime" {
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

                print("Date Frequencies: \(dateFrequencies)")
                print("Time Frequencies: \(timeFrequencies)")

                // Find the most common date
                let mostCommonDate = dateFrequencies.max(by: { $0.value < $1.value })?.key ?? ""
                print("Most Common Date: \(mostCommonDate)")

                // Find the most common time for that date
                guard let dateTimes = timeFrequencies[mostCommonDate] else {
                    self.earliestFoundDate = "No times available"
                    return
                }

                let mostCommonTimes = dateTimes.filter { $0.value == dateTimes.values.max() }
                print("Most Common Times: \(mostCommonTimes)")

                // If there's a tie, find the closest time to the preferred time
                let closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes.keys))
                self.earliestFoundDate = "Date: \(mostCommonDate), Closest Time: \(closestTime)"
            }
    }

    private func findClosestTime(to preferredTime: String, from times: [String]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current  // Ensure consistent time zone
        
        guard let preferredDate = formatter.date(from: preferredTime) else {
            print("Invalid preferred time format")
            return ""
        }
        
        let timeDifferences = times.compactMap { time -> (String, TimeInterval)? in
            guard let date = formatter.date(from: time) else {
                print("Invalid time format: \(time)")
                return nil
            }
            let difference = abs(date.timeIntervalSince(preferredDate))
            print("Time: \(time), Difference: \(difference)")
            return (time, difference)
        }
        
        // Determine the closest time, handling ties by picking the first closest one
        let closestTime = timeDifferences.min(by: { $0.1 < $1.1 })?.0 ?? ""
        print("Closest Time: \(closestTime)")
        return closestTime
    }
}
