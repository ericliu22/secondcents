import SwiftUI
import Firebase

struct CalendarView: View {
    var spaceId: String
    var widgetId: String
    
    @State private var selectedDates: Set<DateComponents> = []
    @State private var localChosenDates: [Date: Set<Date>] = [:]
    @State private var previousSelectedDates: Set<DateComponents> = []
    @State private var currentlySelectedDate: Date? = nil
    @State private var preferredTime: Date? = nil
    @State private var isDatePickerEnabled: Bool = false // Control the enabled/disabled state of the date picker
    @State private var timeSlotUserCounts: [Date: Int] = [:]

    
    let dateFormatterMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // Compute the current date and the bounds
    private var startDate: Date {
        let now = Date()
        let calendar = Calendar.current
        
        if let preferredTime = preferredTime {
            let preferredTimeToday = calendar.date(bySettingHour: calendar.component(.hour, from: preferredTime),
                                                   minute: calendar.component(.minute, from: preferredTime),
                                                   second: 0,
                                                   of: now)!
            
            let cutoffTime = calendar.date(byAdding: .hour, value: 2, to: preferredTimeToday)!
            
            if now > cutoffTime {
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            }
        }
        
        return calendar.startOfDay(for: now)
    }
    
    private var bounds: Range<Date> {
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        return startDate..<endDate
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollView {
            VStack {
                MultiDatePicker("Select Dates", selection: $selectedDates, in: bounds)
                    .disabled(!isDatePickerEnabled) // Disable the date picker if not enabled
                    .onChange(of: selectedDates) { newSelection in
                        handleDateSelectionChange(newSelection)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                if let selectedDate = currentlySelectedDate {
                    VStack {
                        LazyVGrid(columns: columns, spacing: nil) {
                            ForEach(timeSlots(for: selectedDate), id: \.self) { timeSlot in
                                let isPast = isTimeSlotInPast(timeSlot)
                                let isChosen = localChosenDates[selectedDate]?.contains(timeSlot) == true
                                let buttonColor: Color = isPast ? .gray : (isChosen ? .green : .red)
                                let userCount = timeSlotUserCounts[timeSlot, default: 0]  // Get the user count

                                Button {
                                    toggleTimeSelection(timeSlot, for: selectedDate)
                                    
                                    //haptic
                                    
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    
                                    
                                } label: {
                                    VStack {
                                        Text(formatTime(timeSlot))
                                            .fontWeight(.semibold)
                                            .foregroundColor(buttonColor)
                                            .frame(maxWidth: .infinity)
                                        
                                        if areTimesEqual(timeSlot: timeSlot, preferredTime: preferredTime ?? Date()) {
                                            Text("Proposed Time")
                                                .font(.caption)
                                            
                                                .foregroundColor(buttonColor)
                                                .frame(maxWidth: .infinity)
                                        }
                                        
                                        Text("\(userCount) Selected")  // Display the user count
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .frame(height: 100)
                                }
                                .buttonStyle(.bordered)
                                .disabled(isPast) // Disable the button if the time slot is in the past
                                .tint(buttonColor)
                            }
                        }

                        .padding(.horizontal)
                    }
                } else {
                    if isDatePickerEnabled {
                        Text("Select Availability for Start Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                        
                        Spacer()
                    } else {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                loadSavedDates()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDates()
                    }
                }
            }
        }
        .navigationTitle(currentlySelectedDate.map { dateFormatterMonthDay.string(from: $0) } ?? "Select Availability")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleDateSelectionChange(_ newSelection: Set<DateComponents>) {
        // Using async to safely update state and avoid collection view conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let addedDates = newSelection.subtracting(previousSelectedDates)
            let removedDates = previousSelectedDates.subtracting(newSelection)
            
            let calendar = Calendar.current
            
            if let addedDateComponents = addedDates.first,
               let selectedDate = calendar.date(from: addedDateComponents) {
                currentlySelectedDate = selectedDate
                if localChosenDates[selectedDate] == nil {
                    localChosenDates[selectedDate] = Set(timeSlots(for: selectedDate))
                }
            }
            
            if let removedDateComponents = removedDates.first,
               let selectedDate = calendar.date(from: removedDateComponents) {
                localChosenDates.removeValue(forKey: selectedDate)
                selectedDates.remove(calendar.dateComponents([.calendar, .era, .year, .month, .day], from: selectedDate))
                if currentlySelectedDate == selectedDate {
                    currentlySelectedDate = nil
                }
            }
            
            previousSelectedDates = newSelection
        }
    }
    
    private func timeSlots(for date: Date) -> [Date] {
        var timeSlots: [Date] = []
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        let preferredHour = preferredTime != nil ? calendar.component(.hour, from: preferredTime!) : 12
        
        for hour in (preferredHour - 2)...(preferredHour + 2) {
            for minute in [0, 30] {
                var components = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: hour, minute: minute)
                if let timeSlot = calendar.date(from: components) {
                    timeSlots.append(timeSlot)
                }
            }
        }
        return timeSlots
    }
    
    private func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
    
    private func toggleTimeSelection(_ timeSlot: Date, for date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var updatedTimes = localChosenDates[date] ?? Set<Date>()
            
            if updatedTimes.contains(timeSlot) {
                updatedTimes.remove(timeSlot)
                if updatedTimes.isEmpty {
                    localChosenDates.removeValue(forKey: date)
                    selectedDates.remove(Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: date))
                } else {
                    localChosenDates[date] = updatedTimes
                }
            } else {
                updatedTimes.insert(timeSlot)
                localChosenDates[date] = updatedTimes
            }
        }
    }
    func saveDates() {
        let db = Firestore.firestore()
        let userId = try! AuthenticationManager.shared.getAuthenticatedUser().uid

        var saveData: [String: [String]] = [:]
        var updatedTimeSlotCounts: [String: [String: Int]] = [:]

        let currentDate = Date()
        let calendar = Calendar.current

        // Compare current localChosenDates with previously saved dates
        for (date, times) in localChosenDates {
            let filteredTimes: Set<Date>
            if calendar.isDateInToday(date) {
                filteredTimes = times.filter { $0 > currentDate }
            } else {
                filteredTimes = times
            }

            if !filteredTimes.isEmpty {
                let dateKey = dateFormatter.string(from: date)
                let timeStrings = filteredTimes.map { formatTime($0) }
                saveData[dateKey] = timeStrings
            }
        }

        let preferredTimeString = preferredTime != nil ? timeFormatter.string(from: preferredTime!) : ""

        let documentRef = db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)

        documentRef.getDocument { document, error in
            if let error = error {
                print("Error retrieving data: \(error)")
                return
            }

            var mergedTimeSlotCounts: [String: [String: Int]] = [:]
            var previousTimeSlotSelections: [String: Set<String>] = [:]

            if let document = document, document.exists, let data = document.data(),
               let existingTimeSlotCounts = data["timeSlotCounts"] as? [String: [String: Int]],
               let previousUserDates = data[userId] as? [String: [String]] {

                // Convert previousUserDates to a Set structure for easy comparison
                previousTimeSlotSelections = previousUserDates.mapValues { Set($0) }

                mergedTimeSlotCounts = existingTimeSlotCounts

                // Update counts based on changes between previous and current selections
                for (dateKey, newTimes) in saveData {
                    let newTimeSet = Set(newTimes)
                    let previousTimeSet = previousTimeSlotSelections[dateKey] ?? Set<String>()

                    // Determine added and removed times
                    let addedTimes = newTimeSet.subtracting(previousTimeSet)
                    let removedTimes = previousTimeSet.subtracting(newTimeSet)

                    // Update timeSlotCounts
                    var updatedCounts = mergedTimeSlotCounts[dateKey] ?? [:]
                    for timeString in addedTimes {
                        updatedCounts[timeString, default: 0] += 1
                    }
                    for timeString in removedTimes {
                        updatedCounts[timeString, default: 0] -= 1
                        if updatedCounts[timeString]! <= 0 {
                            updatedCounts[timeString] = nil
                        }
                    }
                    if !updatedCounts.isEmpty {
                        mergedTimeSlotCounts[dateKey] = updatedCounts
                    } else {
                        mergedTimeSlotCounts.removeValue(forKey: dateKey)
                    }
                }

                // Handle dates that were fully removed (not present in current selections)
                let removedDates = Set(previousTimeSlotSelections.keys).subtracting(saveData.keys)
                for removedDateKey in removedDates {
                    if let removedTimes = previousTimeSlotSelections[removedDateKey] {
                        var updatedCounts = mergedTimeSlotCounts[removedDateKey] ?? [:]
                        for timeString in removedTimes {
                            updatedCounts[timeString, default: 0] -= 1
                            if updatedCounts[timeString]! <= 0 {
                                updatedCounts[timeString] = nil
                            }
                        }
                        if !updatedCounts.isEmpty {
                            mergedTimeSlotCounts[removedDateKey] = updatedCounts
                        } else {
                            mergedTimeSlotCounts.removeValue(forKey: removedDateKey)
                        }
                    }
                }

            } else {
                // If there's no previous data, simply save the new data
                for (dateKey, timeStrings) in saveData {
                    for timeString in timeStrings {
                        updatedTimeSlotCounts[dateKey, default: [:]][timeString, default: 0] += 1
                    }
                }
                mergedTimeSlotCounts = updatedTimeSlotCounts
            }

            // Update Firestore with merged data
            documentRef.updateData([
                userId: saveData,
                "preferredTime": preferredTimeString,
                "timeSlotCounts": mergedTimeSlotCounts
            ]) { error in
                if let error = error {
                    print("Error updating data: \(error)")
                    documentRef.setData([
                        userId: saveData,
                        "preferredTime": preferredTimeString,
                        "timeSlotCounts": mergedTimeSlotCounts
                    ]) { setError in
                        if let setError = setError {
                            print("Error setting data: \(setError)")
                        } else {
                            print("Data saved successfully")
                        }
                    }
                } else {
                    print("Data updated successfully")
                }
            }
        }
    }


    private func loadSavedDates() {
        let db = Firestore.firestore()
        
        guard let userId: String = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
            return
        }
        
        db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    print("Document does not exist or failed to retrieve data")
                    return
                }
                
                if let data = document.data() {
                    if let preferredTimeString = data["preferredTime"] as? String {
                        self.preferredTime = self.timeFormatter.date(from: preferredTimeString)
                    }
                    
                    if let userDates = data[userId] as? [String: [String]] {
                        var groupedDates: [Date: Set<Date>] = [:]
                        
                        for (dateString, timeStrings) in userDates {
                            if let date = dateFormatter.date(from: dateString) {
                                let times = timeStrings.compactMap { self.parseTime($0, on: date) }
                                groupedDates[date] = Set(times)
                            }
                        }
                        
                        self.localChosenDates = groupedDates
                        self.selectedDates = Set(groupedDates.keys.map { Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: $0) })
                        updateCurrentlySelectedDate()
                    }
                    
                    if let timeSlotCounts = data["timeSlotCounts"] as? [String: [String: Int]] {
                        self.timeSlotUserCounts = timeSlotCounts.flatMap { dateKey, timeCounts in
                            timeCounts.map { timeString, count in
                                let date = self.dateFormatter.date(from: dateKey)!
                                let timeSlot = self.timeFormatter.date(from: timeString)!
                                return (self.mergeDateAndTime(date: date, time: timeSlot), count)
                            }
                        }.reduce(into: [Date: Int]()) { $0[$1.0] = $1.1 }
                    }
                    
                    isDatePickerEnabled = true // Enable the date picker after loading data
                }
            }
    }

    private func mergeDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: timeComponents.hour!, minute: timeComponents.minute!, second: 0, of: date)!
    }

    
    private func updateCurrentlySelectedDate() {
        if let selectedDate = selectedDates.first.flatMap({ Calendar.current.date(from: $0) }) {
            currentlySelectedDate = selectedDate
            if localChosenDates[selectedDate] == nil {
                loadTimesForDate(selectedDate) { savedTimes in
                    DispatchQueue.main.async {
                        if let savedTimes = savedTimes, !savedTimes.isEmpty {
                            localChosenDates[selectedDate] = Set(savedTimes)
                        } else {
                            localChosenDates[selectedDate] = Set(timeSlots(for: selectedDate))
                        }
                    }
                }
            }
        } else {
            if let date = currentlySelectedDate {
                localChosenDates.removeValue(forKey: date)
                selectedDates.remove(Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: date))
            }
            currentlySelectedDate = nil
        }
    }
    
    private func loadTimesForDate(_ date: Date, completion: @escaping ([Date]?) -> Void) {
        let db = Firestore.firestore()
        let userId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        let dateKey = dateFormatter.string(from: date)
        
        db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    print("Document does not exist or failed to retrieve data")
                    completion(nil)
                    return
                }
                
                if let userDates = document.data()?[userId] as? [String: [String]],
                   let timeStrings = userDates[dateKey] {
                    let times = timeStrings.compactMap { self.parseTime($0, on: date) }
                    completion(times)
                } else {
                    completion(nil)
                }
            }
    }
    
    private func parseTime(_ timeString: String, on date: Date) -> Date? {
        if let time = timeFormatter.date(from: timeString) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.hour, .minute], from: time)
            components.year = calendar.component(.year, from: date)
            components.month = calendar.component(.month, from: date)
            components.day = calendar.component(.day, from: date)
            return calendar.date(from: components)
        }
        return nil
    }
    
    func areTimesEqual(timeSlot: Date, preferredTime: Date) -> Bool {
        let calendar = Calendar.current
        
        let timeSlotComponents = calendar.dateComponents([.hour, .minute, .second], from: timeSlot)
        let preferredTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: preferredTime)
        
        return timeSlotComponents == preferredTimeComponents
    }
    
    private func isTimeSlotInPast(_ timeSlot: Date) -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(timeSlot) {
            return timeSlot <= currentDate
        }
        
        return false
    }
}
