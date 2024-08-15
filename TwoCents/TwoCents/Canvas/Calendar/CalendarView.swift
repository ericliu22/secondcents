import SwiftUI
import Firebase

struct CalendarView: View {
    var spaceId: String
    var widget: CanvasWidget
    
    @State private var selectedDates: Set<DateComponents> = []
    @State private var localChosenDates: [Date: Set<Date>] = [:]
    @State private var previousSelectedDates: Set<DateComponents> = []
    @State private var currentlySelectedDate: Date? = nil
    @State private var preferredTime: Date? = nil
    @State private var isDatePickerEnabled: Bool = false // Control the enabled/disabled state of the date picker
    
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
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var bounds: Range<Date> {
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: today)!
        return today..<endDate
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
                                VStack{
                                    Text(formatTime(timeSlot))
                                        .fontWeight(.semibold)
                                        .foregroundColor((localChosenDates[selectedDate]?.contains(timeSlot) == true ? Color.green : Color.red))
                                        .frame(maxWidth: .infinity)
                                    
                                    if areTimesEqual(timeSlot: timeSlot, preferredTime: preferredTime ?? Date.now) {
                                        Text("Proposed Time")
                                            .font(.caption)
                                            .foregroundColor((localChosenDates[selectedDate]?.contains(timeSlot) == true ? Color.green : Color.red))
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .contentShape(Rectangle())
                                .frame(height: 100)
                                .background(.regularMaterial)
                                .background((localChosenDates[selectedDate]?.contains(timeSlot) == true ? Color.green : Color.red))
                                .cornerRadius(10)
                                .onTapGesture {
                                    toggleTimeSelection(timeSlot, for: selectedDate)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    
                    if isDatePickerEnabled {
                     
                        Text("Select Availablity for Start Time")
                            .font(.caption)
                            .foregroundColor(Color.secondary)
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
        .navigationTitle("\(currentlySelectedDate.map { "\(dateFormatterMonthDay.string(from: $0))" } ?? "Select Availability")")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleDateSelectionChange(_ newSelection: Set<DateComponents>) {
        let addedDates = newSelection.subtracting(previousSelectedDates)
        let removedDates = previousSelectedDates.subtracting(newSelection)
        
        if let addedDateComponents = addedDates.first {
            let calendar = Calendar.current
            if let selectedDate = calendar.date(from: addedDateComponents) {
                currentlySelectedDate = selectedDate
                if localChosenDates[selectedDate] == nil {
                    localChosenDates[selectedDate] = Set(timeSlots(for: selectedDate))
                }
            }
        }
        
        if let removedDateComponents = removedDates.first {
            let calendar = Calendar.current
            if let selectedDate = calendar.date(from: removedDateComponents) {
                localChosenDates.removeValue(forKey: selectedDate)
                selectedDates.remove(Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: selectedDate))
                currentlySelectedDate = nil
            }
        }
        
        previousSelectedDates = newSelection
    }
    
    private func timeSlots(for date: Date) -> [Date] {
        var timeSlots: [Date] = []
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        let defaultPreferredHour = 12
        let preferredHour = (preferredTime != nil) ? Calendar.current.component(.hour, from: preferredTime!) : defaultPreferredHour
        
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
    func saveDates() {
        let db = Firestore.firestore()
        let userId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
        var saveData: [String: [String]] = [:]
        
        let currentDate = Date()
        
        for (date, times) in localChosenDates {
            // Only save the dates that are in the future
            if date >= currentDate {
                let dateKey = dateFormatter.string(from: date)
                let timeStrings = times.map { formatTime($0) }
                saveData[dateKey] = timeStrings
            }
        }
        
        let preferredTimeString = preferredTime != nil ? timeFormatter.string(from: preferredTime!) : ""
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .updateData([
                userId: saveData,
                "preferredTime": preferredTimeString
            ]) { error in
                if let error = error {
                    print("Error updating data: \(error)")
                    db.collection("spaces")
                        .document(spaceId)
                        .collection("dates")
                        .document(widget.id.uuidString)
                        .setData([
                            userId: saveData,
                            "preferredTime": preferredTimeString
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

    
    private func loadSavedDates() {
        let db = Firestore.firestore()

        guard let userId: String = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
            return
        }
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
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
                }
                isDatePickerEnabled = true // Enable the date picker after loading data
            }
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
            .collection("dates")
            .document(widget.id.uuidString)
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
}
