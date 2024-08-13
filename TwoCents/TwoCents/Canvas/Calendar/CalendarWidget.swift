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
                
                let preferredTime = data["preferredTime"] as? String ?? self.preferredTime
                print("Preferred Time: \(preferredTime)")

                var dateFrequencies: [String: Int] = [:]
                var timeFrequencies: [String: [String: Int]] = [:]

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

                // Find the date(s) with the highest frequency
                let maxFrequency = dateFrequencies.values.max() ?? 0
                let mostCommonDates = dateFrequencies.filter { $0.value == maxFrequency }.keys.sorted()

                // Select the earliest date among the tied ones
                let mostCommonDate = mostCommonDates.min() ?? ""
                print("Most Common Date: \(mostCommonDate)")

                guard let dateTimes = timeFrequencies[mostCommonDate] else {
                    self.earliestFoundDate = "No times available"
                    return
                }

                // Find the time with the highest frequency for the most common date
                let maxTimeFrequency = dateTimes.values.max() ?? 0
                let mostCommonTimes = dateTimes.filter { $0.value == maxTimeFrequency }.keys
                
                // Find the closest time to the preferred time
                let closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes))
                self.earliestFoundDate = "Date: \(mostCommonDate), Closest Time: \(closestTime)"
            }
    }

    private func findClosestTime(to preferredTime: String, from times: [String]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current
        
        guard let preferredDate = formatter.date(from: preferredTime) else {
            print("Invalid preferred time format")
            return ""
        }
        
        // Convert all times to Date objects and calculate differences
        let timeDifferences = times.compactMap { time -> (String, TimeInterval)? in
            guard let date = formatter.date(from: time) else {
                print("Invalid time format: \(time)")
                return nil
            }
            let difference = abs(date.timeIntervalSince(preferredDate))
            return (time, difference)
        }
        
        // Sort by time difference first, then by time itself for ties
        let closestTime = timeDifferences.sorted {
            if $0.1 == $1.1 {
                // If the time difference is the same, pick the earlier time
                return formatter.date(from: $0.0)! < formatter.date(from: $1.0)!
            } else {
                return $0.1 < $1.1
            }
        }.first?.0 ?? ""
        
        print("Closest Time: \(closestTime)")
        return closestTime
    }
}
