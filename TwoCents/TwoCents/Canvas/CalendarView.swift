import SwiftUI
import Firebase

struct TimeSlot: Identifiable {
    var id = UUID()
    var time: Date
    var chosen: Bool = true
}

struct CalendarView: View {
    @State private var selectedDates: Set<DateComponents> = []
    @State private var savedDates: [Date] = []
    @State private var currentSelectedDate: Date? = nil
    @State private var timeSlots: [TimeSlot] = []
    var spaceId: String
    var widget: CanvasWidget

    var body: some View {
        VStack {
            MultiDatePicker("Select dates", selection: $selectedDates)
                .padding()
                .onChange(of: selectedDates) { oldValue, newValue in
                    handleDateSelectionChange(oldValue: oldValue, newValue: newValue)
                }
            Text("Selected Date: \(currentSelectedDate?.description ?? "None")")
            List(timeSlots) { timeSlot in
                HStack {
                    Text(formattedTime(timeSlot.time))
                    Spacer()
                    Text(timeSlot.chosen ? "Chosen" : "Not Chosen")
                        .foregroundColor(timeSlot.chosen ? .green : .red)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleTimeSlotChosen(timeSlot: timeSlot)
                }
            }
        }
        .onAppear {
            loadSavedDates()
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    func handleDateSelectionChange(oldValue: Set<DateComponents>, newValue: Set<DateComponents>) {
        let calendar = Calendar.current
        if let newDateComponents = newValue.first(where: { !oldValue.contains($0) }),
           let newDate = calendar.date(from: newDateComponents) {
            currentSelectedDate = newDate
            timeSlots = generateTimeSlots(for: newDate)
            saveAllTimeSlots(for: newDate)
        } else if let removedDateComponents = oldValue.first(where: { !newValue.contains($0) }),
                  let removedDate = calendar.date(from: removedDateComponents) {
            currentSelectedDate = nil
            removeDate(from: removedDate)
        }
    }

    func generateTimeSlots(for selectedDate: Date) -> [TimeSlot] {
        var timeSlots: [TimeSlot] = []
        let calendar = Calendar.current

        // Set the base time to 2 PM
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        dateComponents.hour = 14 // 2 PM
        dateComponents.minute = 0

        if let selectedTime = calendar.date(from: dateComponents), let startTime = calendar.date(byAdding: .hour, value: -2, to: selectedTime) {
            for i in 0...8 {
                if let newTime = calendar.date(byAdding: .minute, value: i * 30, to: startTime) {
                    timeSlots.append(TimeSlot(time: newTime))
                }
            }
        }
        return timeSlots
    }

    func toggleTimeSlotChosen(timeSlot: TimeSlot) {
        if let index = timeSlots.firstIndex(where: { $0.id == timeSlot.id }) {
            timeSlots[index].chosen.toggle()
            if timeSlots[index].chosen {
                saveDates(for: currentSelectedDate)
            } else {
                removeTimeSlot(timeSlot, from: currentSelectedDate)
            }
        }
    }

    func saveAllTimeSlots(for date: Date) {
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

        let chosenSlots = timeSlots.map { dateFormatterWithTime.string(from: $0.time) }

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String]] ?? [:]

                if !chosenSlots.isEmpty {
                    if var userDates = existingData[uid] {
                        // Append the new dates, ensuring there are no duplicates
                        userDates.append(contentsOf: chosenSlots)
                        existingData[uid] = Array(Set(userDates)) // Remove duplicates, if any
                    } else {
                        existingData[uid] = chosenSlots
                    }
                }

                db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .setData(existingData)
            }
    }

    func saveDates(for date: Date?) {
        guard let date = date else { return }

        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

        let chosenSlots = timeSlots.filter { $0.chosen }.map { dateFormatterWithTime.string(from: $0.time) }

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String]] ?? [:]

                if !chosenSlots.isEmpty {
                    if var userDates = existingData[uid] {
                        // Append the new dates, ensuring there are no duplicates
                        userDates.append(contentsOf: chosenSlots)
                        existingData[uid] = Array(Set(userDates)) // Remove duplicates, if any
                    } else {
                        existingData[uid] = chosenSlots
                    }
                }

                db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .setData(existingData)
            }
    }

    func removeTimeSlot(_ timeSlot: TimeSlot, from date: Date?) {
        guard let date = date else { return }
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        let timeSlotString = dateFormatterWithTime.string(from: timeSlot.time)

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String]] ?? [:]
                if var userDates = existingData[uid] {
                    userDates.removeAll { $0 == timeSlotString }
                    if userDates.isEmpty {
                        existingData.removeValue(forKey: uid)
                    } else {
                        existingData[uid] = userDates
                    }
                }

                db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .setData(existingData)
            }
    }

    func removeDate(from date: Date) {
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        let dateString = dateFormatterWithTime.string(from: date)

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String]] ?? [:]
                if var userDates = existingData[uid] {
                    userDates.removeAll { $0 == dateString }
                    if userDates.isEmpty {
                        existingData.removeValue(forKey: uid)
                    } else {
                        existingData[uid] = userDates
                    }
                }

                db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .setData(existingData)
            }
    }

    private let dateFormatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        return formatter
    }()

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    func loadSavedDates() {
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                if let document = document, document.exists {
                    // Load only the data associated with the current user ID
                    if let userDates = document.data()?[uid] as? [String] {
                        self.savedDates = userDates.compactMap { dateFormatterWithTime.date(from: $0) }.sorted()
                        let calendar = Calendar.current
                        self.selectedDates = Set(self.savedDates.map { calendar.dateComponents([.calendar, .era, .year, .month, .day], from: $0) })

                        // Automatically reload time slots for the first saved date
                        if let firstDate = self.savedDates.first {
                            self.currentSelectedDate = firstDate
                            self.timeSlots = generateTimeSlots(for: firstDate)
                        }
                    }
                } else {
                    print("Document does not exist or failed to retrieve data")
                }
            }
    }
}
