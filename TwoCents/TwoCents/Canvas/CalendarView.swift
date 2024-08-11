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
    @State private var selectedTime: String = ""
    @State private var currentSelectedDate: Date? = nil
    @State private var timeSlots: [TimeSlot] = []
    var spaceId: String
    var widget: CanvasWidget

    var body: some View {
        VStack {
            Text("Preferred Time: " + selectedTime)
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
            timeSlots = generateTimeSlots(from: selectedTime, for: newDate)
            saveDates(for: newDate)
        } else if let removedDateComponents = oldValue.first(where: { !newValue.contains($0) }),
                  let removedDate = calendar.date(from: removedDateComponents) {
            currentSelectedDate = nil
            removeDate(from: removedDate)
        }
    }

    func generateTimeSlots(from selectedTimeString: String, for selectedDate: Date) -> [TimeSlot] {
        var timeSlots: [TimeSlot] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mma"

        guard let selectedTime = dateFormatter.date(from: "\(dateFormatter.string(from: selectedDate)) \(selectedTimeString)") else {
            print("Invalid time string")
            return timeSlots
        }

        if let startTime = calendar.date(byAdding: .hour, value: -2, to: selectedTime) {
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
            saveDates(for: currentSelectedDate)
        }
    }

    func saveDates(for date: Date?) {
        guard let date = date else { return }

        let db = Firestore.firestore()
        let calendar = Calendar.current
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

        let dateString = dateFormatter.string(from: date)
        let chosenSlots = timeSlots.filter { $0.chosen }.map { formattedTime($0.time) }

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String: [String]]] ?? [:]

                if !chosenSlots.isEmpty {
                    if existingData[uid] == nil {
                        existingData[uid] = [:]
                    }
                    existingData[uid]?[dateString] = chosenSlots
                } else {
                    existingData[uid]?.removeValue(forKey: dateString)
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
        let dateString = dateFormatter.string(from: date)

        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { document, error in
                var existingData = document?.data() as? [String: [String: [String]]] ?? [:]
                existingData[uid]?.removeValue(forKey: dateString)

                db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .setData(existingData)
            }
    }

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
                if let document = document {
                    if let dateMap = document.data()?[uid] as? [String: [String]] {
                        self.savedDates = dateMap.keys.compactMap { dateFormatter.date(from: $0) }.sorted()
                        let calendar = Calendar.current
                        self.selectedDates = Set(self.savedDates.map { calendar.dateComponents([.calendar, .era, .year, .month, .day], from: $0) })

                        // Automatically reload time slots for the first saved date
                        if let firstDate = self.savedDates.first {
                            self.currentSelectedDate = firstDate
                            self.timeSlots = generateTimeSlots(from: self.selectedTime, for: firstDate)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
    }
}
