import Foundation
import SwiftUI
import Firebase

struct OptimalDate {
    var shortMonth: String?
    var longMonth: String?
    var day: String?
    var dayOfWeek: String?
    var date: Date?
    
    init(from dateString: String) {
        guard !dateString.isEmpty else {
            self.shortMonth = nil
            self.longMonth = nil
            self.day = nil
            self.dayOfWeek = nil
            self.date = nil
            return
        }
        
        // Create a date formatter for the initial date parsing
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Try to parse the date string into a Date object
        if let date = dateFormatter.date(from: dateString) {
            self.date = date
            
            // Extracting the month in words
            dateFormatter.dateFormat = "MMM"
            self.shortMonth = dateFormatter.string(from: date)
            
            // Extracting the month in words
            dateFormatter.dateFormat = "MMMM"
            self.longMonth = dateFormatter.string(from: date)
            
            // Extracting the day in numbers
            dateFormatter.dateFormat = "dd"
            self.day = dateFormatter.string(from: date)
            
            // Extracting the day of the week in words
            dateFormatter.dateFormat = "EEE"
            self.dayOfWeek = dateFormatter.string(from: date)
        } else {
            self.shortMonth = nil
            self.longMonth = nil
            self.day = nil
            self.dayOfWeek = nil
            self.date = nil
        }
    }
}
struct CalendarWidget: View {
    let widget: CanvasWidget

    @State private var closestTime: String = ""
    @State private var idsWithoutDate: [String] = []
    @State private var userColor: Color = .gray
    var spaceId: String
    private let preferredTime: String = "7:00 PM" // Set your preferred time here
    
    @State private var bounce = false
    @State private var optimalDate = OptimalDate(from: "")
    
    var body: some View {
        ZStack {
            Color(UIColor.tertiarySystemFill)
            VStack {
                if let date = optimalDate.date {
                    if isTodayOrTomorrow(date: date) && !hasDatePassed(date: date, time: closestTime) {
                        // Event is today or tomorrow and hasn't passed yet
                        EventTimeView(optimalDate: $optimalDate, closestTime: $closestTime)
                    } else if hasDatePassed(date: date, time: closestTime) {
                        // Event has passed
                        EventPassedView(optimalDate: $optimalDate, closestTime: $closestTime)
                    } else {
                        // Event is in the future (beyond tomorrow)
                        EventDateView(optimalDate: $optimalDate, closestTime: $closestTime)
                    }
                } else {
                    EmptyEventView()
                }
            }
            .background(Color(UIColor.systemBackground))
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
                    DispatchQueue.main.async {
                        self.optimalDate = OptimalDate(from: "")
                        self.closestTime = "" // Clear the closestTime when there's no date
                    }
                    return
                }

                let data = document.data() ?? [:]
                print("Fetched data: \(data)")

                let preferredTime = data["preferredTime"] as? String ?? self.preferredTime
                print("Preferred Time: \(preferredTime)")

                let (mostCommonDate, closestTime) = findOptimalDateAndTime(from: data, preferredTime: preferredTime)

                // Ensure UI updates happen on the main thread
                DispatchQueue.main.async {
                    self.optimalDate = OptimalDate(from: mostCommonDate)
                    self.closestTime = closestTime
                }
            }
    }
    
    private func findOptimalDateAndTime(from data: [String: Any], preferredTime: String) -> (String, String) {
        var dateFrequencies: [String: Int] = [:]
        var timeFrequencies: [String: [String: Int]] = [:]
        let currentDate = Date()
        let calendar = Calendar.current

        for (userId, userDates) in data where userId != "preferredTime" {
            guard let userDatesDict = userDates as? [String: [String]] else { continue }

            for (dateString, times) in userDatesDict {
                // Parse the date string to a Date object
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatter.date(from: dateString) else {
                    continue // Skip invalid dates
                }

                // Process times only if they are in the future or today but not yet passed
                let validTimes = times.filter { time in
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    timeFormatter.timeZone = TimeZone.current
                    guard let timeDate = timeFormatter.date(from: time) else {
                        return false
                    }
                    
                    // Combine the date with the time to create a full Date object
                    let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                                     minute: calendar.component(.minute, from: timeDate),
                                                     second: 0,
                                                     of: date)
                    
                    // Only include times that are in the future or today but not yet passed
                    return combinedDate ?? currentDate > currentDate || Calendar.current.isDateInToday(date) && combinedDate! >= currentDate
                }

                if validTimes.isEmpty {
                    continue // Skip this date if all times are in the past
                }

                dateFrequencies[dateString, default: 0] += 1

                if timeFrequencies[dateString] == nil {
                    timeFrequencies[dateString] = [:]
                }

                for time in validTimes {
                    timeFrequencies[dateString]?[time, default: 0] += 1
                }
            }
        }

        print("Date Frequencies: \(dateFrequencies)")
        print("Time Frequencies: \(timeFrequencies)")

        if dateFrequencies.isEmpty {
            return ("", "")
        }

        // Find the date(s) with the highest frequency
        let maxFrequency = dateFrequencies.values.max() ?? 0
        let mostCommonDates = dateFrequencies.filter { $0.value == maxFrequency }.keys.sorted()

        // Select the earliest date among the tied ones
        let mostCommonDate = mostCommonDates.min() ?? ""
        print("Most Common Date: \(mostCommonDate)")

        guard let dateTimes = timeFrequencies[mostCommonDate] else {
            return ("", "")
        }

        // Find the time with the highest frequency for the most common date
        let maxTimeFrequency = dateTimes.values.max() ?? 0
        let mostCommonTimes = dateTimes.filter { $0.value == maxTimeFrequency }.keys

        // Find the closest time to the preferred time
        let closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes))

        return (mostCommonDate, closestTime)
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
    private func isTodayOrTomorrow(date: Date) -> Bool {
        let calendar = Calendar.current
        
        // Check if the event is today
        if calendar.isDateInToday(date) {
            return true
        }
        
        // Check if the event is tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()), calendar.isDate(date, inSameDayAs: tomorrow) {
            return true
        }
        
        return false
    }

    
    private func hasDatePassed(date: Date, time: String) -> Bool {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.current
        
        guard let timeDate = timeFormatter.date(from: time) else {
            return true // Treat as passed if time parsing fails
        }
        
        // Combine the date with the time to create a full Date object
        let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                         minute: calendar.component(.minute, from: timeDate),
                                         second: 0,
                                         of: date) ?? date
        
        // Check if the given date and time combination is earlier than the current date and time
        return combinedDate < Date()
    }

}


// VIEW FOR WHEN THERE IS NO OPTIMAL DATE
struct EmptyEventView: View {
    @State private var bounce: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Grind Sesh")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Spacer()
            
            Text("😔")
                .font(.system(size: 44))
                .foregroundColor(.primary)
                .overlay {
                    Text("🤘")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .offset(x: -28, y: -4)
                        .offset(y: bounce ? 3 : 0)
                        .animation(
                            Animation.easeInOut(duration: 1)
                                .repeatForever(autoreverses: true)
                        )
                        .onAppear {
                            bounce.toggle()
                        }
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 2, y: 0)
                        .rotationEffect(.degrees(-10))
                }
            
            Spacer()
            
            Button(action: {
                // Add button action here
            }, label: {
                Text("Party Together!")
                    .font(.caption2)
            })
            .buttonStyle(.bordered)
            .foregroundColor(Color.accentColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// VIEW FOR WHEN DATE IS MORE THAN 24 HOURS AWAY
struct EventDateView: View {
    @State private var bounce: Bool = false
 
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Grind Sesh")
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            if let date = optimalDate.date {
                let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                
                Text("\(closestTime)・In \(daysDifference) day\(daysDifference != 1 ? "s" : "")")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)
            }
            
            Divider()
            Spacer()

            HStack (spacing: 3) {
                if let dayOfWeek = optimalDate.dayOfWeek {
                    Text(dayOfWeek)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.accentColor)
                }
                
                if let shortMonth = optimalDate.shortMonth {
                    Text(shortMonth)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, -8)
            
            if let day = optimalDate.day {
                Text(day)
                    .font(.system(size: 72))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.vertical, -15)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// VIEW FOR WHEN DATE IS LESS THAN 24 HOURS AWAY
struct EventTimeView: View {
    @State private var bounce: Bool = false
 
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Grind Sesh")
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            if let longMonth = optimalDate.longMonth, let day = optimalDate.day {
                Text("\(longMonth) \(day)")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)
            }
            
            Divider()
            Spacer()
            
            if let date = optimalDate.date {
                Text(Calendar.current.isDateInToday(date) ? "Today" : "Tomorrow")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.accentColor)
                    .padding(.bottom, -5)
            }
            
            Text(closestTime)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// VIEW FOR WHEN EVENT HAS PASSED
struct EventPassedView: View {
    @State private var bounce: Bool = false
    
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Grind Sesh")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            if let longMonth = optimalDate.longMonth, let day = optimalDate.day {
                Text("\(longMonth) \(day)")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
            }
            
            Text(bounce ? "🥳" : "☺️")
                .font(.system(size: 44))
                .foregroundColor(.primary)
                .onAppear {
                    startAnimation()
                }
            
            Spacer()
            
            Text("Til next time!")
                .font(.caption2)
                .foregroundColor(Color.secondary)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func startAnimation() {
        // Reset the state to ensure consistent behavior
        bounce = false
        
        // Add a slight delay to allow the view to fully appear before starting the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let animation = Animation.easeInOut(duration: 1)
                .delay(2.0)
                .repeatForever(autoreverses: true)

            withAnimation(animation) {
                bounce.toggle()
            }
        }
    }
}
