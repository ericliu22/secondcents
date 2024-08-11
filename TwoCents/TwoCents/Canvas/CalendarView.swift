import SwiftUI
import Firebase

struct CalendarView: View {
    var spaceId: String
    var widget: CanvasWidget
    
    @State private var selectedDates: Set<DateComponents> = []
    @State private var localChosenDates: [Date: Set<Date>] = [:]
    @State private var currentlySelectedDate: Date? = nil
    
    let dateFormatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
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
    
    var body: some View {
        VStack {
            MultiDatePicker("Select Dates", selection: $selectedDates)
                .padding()
                .onChange(of: selectedDates) { newSelection in
                    updateCurrentlySelectedDate()
                }
            
            Text("Selected Date: \(currentlySelectedDate.map { dateFormatter.string(from: $0) } ?? "None")")
            
            if let selectedDate = currentlySelectedDate {
                List(timeSlots(for: selectedDate), id: \.self) { timeSlot in
                    HStack {
                        Text(formatTime(timeSlot))
                        Spacer()
                        Text(localChosenDates[selectedDate]?.contains(timeSlot) == true ? "Chosen" : "Not Chosen")
                            .foregroundColor(localChosenDates[selectedDate]?.contains(timeSlot) == true ? .green : .red)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleTimeSelection(timeSlot, for: selectedDate)
                    }
                }
                .animation(.default, value: currentlySelectedDate) // Ensure the list updates smoothly
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
    
    private func updateCurrentlySelectedDate() {
        currentlySelectedDate = selectedDates.first.flatMap { dateComponents in
            Calendar.current.date(from: dateComponents)
        }
        // Optionally, you can trigger additional updates here if needed
    }
    
    private func timeSlots(for date: Date) -> [Date] {
        var timeSlots: [Date] = []
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        for hour in 12...18 {
            let components = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: hour)
            if let timeSlot = calendar.date(from: components) {
                timeSlots.append(timeSlot)
            }
        }
        return timeSlots
    }
    
    private func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
    
    private func toggleTimeSelection(_ timeSlot: Date, for date: Date) {
        if localChosenDates[date] == nil {
            localChosenDates[date] = []
        }
        
        if localChosenDates[date]!.contains(timeSlot) {
            localChosenDates[date]!.remove(timeSlot)
            if localChosenDates[date]!.isEmpty {
                localChosenDates.removeValue(forKey: date)
                selectedDates.remove(Calendar.current.dateComponents([.year, .month, .day], from: date))
            }
        } else {
            localChosenDates[date]!.insert(timeSlot)
        }
    }
    
    private func saveDates() {
        let db = Firestore.firestore()
        let userId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
        var saveData: [String: [String]] = [:]
        
        for (date, times) in localChosenDates {
            let dateKey = dateFormatter.string(from: date)
            let timeStrings = times.map { formatTime($0) }
            saveData[dateKey] = timeStrings
        }
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .setData([userId: saveData]) { error in
                if let error = error {
                    print("Error saving data: \(error)")
                } else {
                    print("Data saved successfully")
                }
            }
    }
    
    private func loadSavedDates() {
        let db = Firestore.firestore()
        let userId = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    print("Document does not exist or failed to retrieve data")
                    return
                }
                
                if let userDates = document.data()?[userId] as? [String: [String]] {
                    var groupedDates: [Date: Set<Date>] = [:]
                    
                    for (dateString, timeStrings) in userDates {
                        if let date = dateFormatter.date(from: dateString) {
                            let times = timeStrings.compactMap { timeFormatter.date(from: $0).flatMap { Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: $0), minute: Calendar.current.component(.minute, from: $0), second: 0, of: date) } }
                            groupedDates[date] = Set(times)
                        }
                    }
                    
                    self.localChosenDates = groupedDates
                    self.selectedDates = Set(groupedDates.keys.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) })
                    updateCurrentlySelectedDate()
                }
            }
    }
}
