import Foundation
import SwiftUI
import Firebase

struct OptimalDate {
    var month: String?
    var day: String?
    var dayOfWeek: String?
    
    init(from dateString: String) {
        guard !dateString.isEmpty else {
            self.month = nil
            self.day = nil
            self.dayOfWeek = nil
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
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
                if optimalDate.day == nil {
                    EmptyEventView()
                } else {
                    
                    
                    VStack(alignment: .center, spacing: 0) {
                  
//                        
                        
                        Text("Grind Sesh")
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        
                        
                        
                        
                        Text("@ \(closestTime)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        
                        
                        
                        HStack (spacing: 6){
                            Text(optimalDate.dayOfWeek!)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.accentColor)
                             
                            
                            Text(optimalDate.month!)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                    
                        }
      
//                        .background(.red)
                        Text(optimalDate.day!)
                            .font(.system(size: 72))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.vertical, -15)
//                            .background(.red)
                        
        
                        
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    DispatchQueue.main.async {
                        self.optimalDate = OptimalDate(from: "")
                    }
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

                if dateFrequencies.isEmpty {
                    DispatchQueue.main.async {
                        self.optimalDate = OptimalDate(from: "")
                    }
                    return
                }

                // Find the date(s) with the highest frequency
                let maxFrequency = dateFrequencies.values.max() ?? 0
                let mostCommonDates = dateFrequencies.filter { $0.value == maxFrequency }.keys.sorted()

                // Select the earliest date among the tied ones
                let mostCommonDate = mostCommonDates.min() ?? ""
                print("Most Common Date: \(mostCommonDate)")

                guard let dateTimes = timeFrequencies[mostCommonDate] else {
                    DispatchQueue.main.async {
                        self.optimalDate = OptimalDate(from: "")
                    }
                    return
                }

                // Find the time with the highest frequency for the most common date
                let maxTimeFrequency = dateTimes.values.max() ?? 0
                let mostCommonTimes = dateTimes.filter { $0.value == maxTimeFrequency }.keys
                
                // Find the closest time to the preferred time
                self.closestTime = findClosestTime(to: preferredTime, from: Array(mostCommonTimes))
        
                DispatchQueue.main.async {
                    self.optimalDate = OptimalDate(from: mostCommonDate)
                }
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

struct EmptyEventView: View {
    @State private var bounce: Bool = false
    var earliestFoundDate: String = ""

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
