import Foundation
import SwiftUI
import Firebase


// Model to handle date formatting
struct OptimalDate {
    var shortMonth: String?
    var longMonth: String?
    var day: String?
    var dayOfWeek: String?
    var date: Date?
    var maxTimeFrequency: Int
    
    init(from dateString: String, maxTimeFrequency: Int) {
        self.maxTimeFrequency = maxTimeFrequency
        
        guard !dateString.isEmpty else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            self.date = date
            
            dateFormatter.dateFormat = "MMM"
            self.shortMonth = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "MMMM"
            self.longMonth = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "dd"
            self.day = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "EEE"
            self.dayOfWeek = dateFormatter.string(from: date)
        }
        

    }
}

// Main view for displaying the calendar widget
struct CalendarWidget: View {
    let widget: CanvasWidget
    var spaceId: String
    private let preferredTime: String = "7:00 PM"

    @State private var closestTime: String = ""
    @State private var optimalDate = OptimalDate(from: "", maxTimeFrequency: 0)
    @State private var eventName: String = "Eventful Event"
    
    @Binding var activeSheet: sheetTypesCanvasPage?
    @Binding var activeWidget: CanvasWidget?
    
    
    var body: some View {
            VStack {
                if let date = optimalDate.date {
                    if isTodayOrTomorrow(date: date) && !hasDatePassed(date: date, time: closestTime) {
                        EventTimeView(optimalDate: $optimalDate, closestTime: $closestTime, eventName: eventName)
                    } else if hasDatePassed(date: date, time: closestTime) {
                        EventPassedView(optimalDate: $optimalDate, closestTime: $closestTime, eventName: eventName)
                    } else {
                        EventDateView(optimalDate: $optimalDate, closestTime: $closestTime, eventName: eventName)
                    }
                } else {
                    EmptyEventView(eventName: eventName, activeSheet: $activeSheet, activeWidget: $activeWidget, widget: widget)
                }
            }
            .background(Color(UIColor.systemBackground))
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .cornerRadius(CORNER_RADIUS)
   
        .task {
            await setupSnapshotListener()
        }
    }

    private func setupSnapshotListener() async {
        let db = Firestore.firestore()

        db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widget.id.uuidString)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }

                guard let document = documentSnapshot, document.exists else {
                    DispatchQueue.main.async {
                        self.optimalDate = OptimalDate(from: "", maxTimeFrequency: 0)
                        self.closestTime = ""
                        self.eventName = "Eventful Event" // Fallback name
                    }
                    return
                }

                let data = document.data() ?? [:]
                let preferredTime = data["preferredTime"] as? String ?? self.preferredTime
                print("PREFERRED TIME IS \(preferredTime)")
                
                let eventName = data["name"] as? String ?? "Eventful Event" // Fetch the event name
                let (mostCommonDate, closestTime, maxTimeFrequency) = findOptimalDateAndTime(from: data, preferredTime: preferredTime)

                DispatchQueue.main.async {
                    if maxTimeFrequency > 1 {
                        self.optimalDate = OptimalDate(from: mostCommonDate, maxTimeFrequency: maxTimeFrequency)
                        self.closestTime = closestTime
                    } else {
                        self.optimalDate = OptimalDate(from: "", maxTimeFrequency: 0)
                        self.closestTime = ""
                    }
                    self.eventName = eventName // Set the event name
                }
            }
    }
    
    private func findOptimalDateAndTime(from data: [String: Any], preferredTime: String) -> (String, String, Int) {
        var dateFrequencies: [String: Int] = [:]
        var timeFrequencies: [String: [String: Int]] = [:]
        let currentDate = Date()
        let calendar = Calendar.current

        for (_, userDates) in data where userDates is [String: [String]] {
            guard let userDatesDict = userDates as? [String: [String]] else { continue }

            for (dateString, times) in userDatesDict {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatter.date(from: dateString) else { continue }

                let validTimes = times.filter { time in
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    timeFormatter.timeZone = TimeZone.current
                    guard let timeDate = timeFormatter.date(from: time) else { return false }

                    let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                                     minute: calendar.component(.minute, from: timeDate),
                                                     second: 0,
                                                     of: date)
                    
                    return combinedDate ?? currentDate > currentDate || Calendar.current.isDateInToday(date) && combinedDate! >= currentDate
                }

                if validTimes.isEmpty { continue }

                dateFrequencies[dateString, default: 0] += 1

                if timeFrequencies[dateString] == nil {
                    timeFrequencies[dateString] = [:]
                }

                for time in validTimes {
                    timeFrequencies[dateString]?[time, default: 0] += 1
                }
            }
        }

        if dateFrequencies.isEmpty { return ("", "", 0) }

        let maxFrequency = dateFrequencies.values.max() ?? 0
        let mostCommonDates = dateFrequencies.filter { $0.value == maxFrequency }.keys.sorted()
        let mostCommonDate = mostCommonDates.min() ?? ""

        guard let dateTimes = timeFrequencies[mostCommonDate] else { return ("", "", 0) }

        let maxTimeFrequency = dateTimes.values.max() ?? 0
        let mostCommonTimes = dateTimes.filter { $0.value == maxTimeFrequency }.keys

        let closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes))

        return (mostCommonDate, closestTime, maxTimeFrequency)
    }

    private func findClosestTime(to preferredTime: String, from times: [String]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current
        
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
            return (time, difference)
        }
        
        let closestTime = timeDifferences.sorted {
            if $0.1 == $1.1 {
                return formatter.date(from: $0.0)! < formatter.date(from: $1.0)!
            } else {
                return $0.1 < $1.1
            }
        }.first?.0 ?? ""
        
        return closestTime
    }

    private func isTodayOrTomorrow(date: Date) -> Bool {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return true
        }
        
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
        
        guard let timeDate = timeFormatter.date(from: time) else { return true }
        
        let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                         minute: calendar.component(.minute, from: timeDate),
                                         second: 0,
                                         of: date) ?? date
        
        return combinedDate < Date()
    }
}

// View for when there is no optimal date
struct EmptyEventView: View {
    @State private var bounce: Bool = false
    var eventName: String
    @Binding var activeSheet: sheetTypesCanvasPage?
    @Binding var activeWidget: CanvasWidget?
    let widget: CanvasWidget
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(eventName)
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
                
                activeSheet = .calendar
                activeWidget = widget
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

// View for when the date is more than 24 hours away
struct EventDateView: View {
    @State private var bounce: Bool = false
 
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String
    var eventName: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(eventName)
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

            HStack(spacing: 3) {
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

// View for when the date is less than 24 hours away
struct EventTimeView: View {
    @State private var bounce: Bool = false
 
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String
    var eventName: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(eventName)
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            
            
           
            
            Text("\(optimalDate.maxTimeFrequency) " + (optimalDate.maxTimeFrequency == 1 ? "Attendee" : "Attendees"))

                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(.secondary)
                .padding(.top, 3)
            
            
        
        
            
            
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// View for when the event has passed
struct EventPassedView: View {
    @State private var bounce: Bool = false
    
    @Binding private(set) var optimalDate: OptimalDate
    @Binding private(set) var closestTime: String
    var eventName: String

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(eventName)
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
        bounce = false
        
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


func deleteCalendar(spaceId: String, calendarId: String) {
    do {
        try db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(calendarId)
            .delete()
    } catch {
        print("Error deleting poll")
    }
}
