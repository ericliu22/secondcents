import Foundation
import SwiftUI
import Firebase


struct OptimalDate {
    var month: String?
    var day: String?
    var dayOfWeek: String?
    var date: Date?
    
    init(from dateString: String) {
        guard !dateString.isEmpty else {
            self.month = nil
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
            self.month = dateFormatter.string(from: date)
            
            // Extracting the day in numbers
            dateFormatter.dateFormat = "dd"
            self.day = dateFormatter.string(from: date)
            
            // Extracting the day of the week in words
            dateFormatter.dateFormat = "EEE"
            self.dayOfWeek = dateFormatter.string(from: date)
        } else {
            self.month = nil
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
                    if isDateWithin24Hours(date) {
                        EventTimeView(optimalDate: $optimalDate, closestTime: $closestTime)
                    } else {
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
    
    private func isDateWithin24Hours(_ date: Date) -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current

        // Calculate the difference between the current date and the given date in hours
        let hoursDifference = calendar.dateComponents([.hour], from: currentDate, to: date).hour ?? 0

        // Check if the difference is within 24 hours
        return hoursDifference <= 24 && hoursDifference >= 0
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
      
//
            
          
            
            
            Text("Grind Sesh")
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
            
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
            Text("@ " + closestTime)
                .font(.caption2)
                .foregroundColor(Color.secondary)
                .fontWeight(.semibold)
            
            
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 3)
            
         
            
            
            Divider()
            
         
         
            
            Spacer()
            
            HStack (spacing: 3){
                Text(optimalDate.dayOfWeek!)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.accentColor)
                 
                
                Text(optimalDate.month!)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
        
            }
            .padding(.top, -8)
        
            
            
            Text(optimalDate.day!)
                .font(.system(size: 72))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.vertical, -15)
//
//                        Text(closestTime)
//                            .font(.caption)
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color.secondary)
//
            
//                        Spacer()
            
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
      
//
            
          
            
            
            Text("Grind Sesh")
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
            
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
            Text("@ " + closestTime)
                .font(.caption2)
                .foregroundColor(Color.secondary)
                .fontWeight(.semibold)
            
            
                .frame(maxWidth: .infinity, alignment: .leading)
            
                .padding(.bottom, 3)
            
         
            
            
            Divider()
            
         
         
            
            Spacer()
            
            
            
            Text(Calendar.current.isDateInToday(optimalDate.date!) ? "Today" : "Tomorrow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
            
         
            
            
            Text(closestTime)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                
            
            
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



