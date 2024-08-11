//
//  CalendarWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 6/22/24.
//


import Foundation
import SwiftUI
import Firebase

struct TimeSlot: Identifiable {
    var id = UUID()
    var time: Date
    var chosen: Bool = true
}

struct CalendarView: View {
    @State var selectedDates: Set<DateComponents> = []
    @State var savedDates: [Date] = []
    @State var selectedTime: String = ""
    @State var currentSelectedDate: Date? = nil
    @State var timeSlots: [TimeSlot] = []
    var spaceId: String
    var widget: CanvasWidget
    

    var body: some View {
        VStack {
            Text("Preferred Time: "+selectedTime)
            MultiDatePicker("Select dates", selection: $selectedDates)
                .padding()
                .onChange(of: selectedDates) { oldValue, newValue in
                    //saveDates(dates: selectedDates)
                    handleDateSelectionChange(oldValue: oldValue, newValue: newValue)
                    self.timeSlots = generateTimeSlots(from: selectedTime, SelectedDate: currentSelectedDate)
                 }
            Text("Selected Date: \(currentSelectedDate)")
            List(timeSlots) { timeSlot in
                HStack {
                    Text(formattedTime(timeSlot.time))
                    Spacer()
                    Text(timeSlot.chosen ? "Chosen" : "Not Chosen")
                        .foregroundColor(timeSlot.chosen ? .green : .red)
                }
            }
//            Button(action: {
//                saveDates(dates: selectedDates)
//            }) {
//                Text("Save Dates")
//            }
            //.padding()
        }
        .onAppear {
            loadSavedDates()
            self.currentSelectedDate = nil
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    /*
     This function checks to see if the date selected is a new date.
     */
    func handleDateSelectionChange(oldValue: Set<DateComponents>, newValue: Set<DateComponents>) {
        let calendar = Calendar.current
        if let newDateComponents = newValue.first(where: { !oldValue.contains($0) }),
           let newDate = calendar.date(from: newDateComponents) {
            currentSelectedDate = newDate
            let dateString = DateFormatter.localizedString(from: newDate, dateStyle: .medium, timeStyle: .none)
        } else if let removedDateComponents = oldValue.first(where: { !newValue.contains($0) }),
                  let removedDate = calendar.date(from: removedDateComponents),
                  removedDate == currentSelectedDate {
            currentSelectedDate = nil
        }
        saveDates(dates: newValue)
    }
    
    
    func generateTimeSlots(from selectedTimeString: String, SelectedDate: Date?) -> [TimeSlot] {
        var timeSlots: [TimeSlot] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        let currentDateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mma"// Adjust the date format as per your input string
        currentDateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let SelectedDate = SelectedDate else {
            print("Selected date is nil")
            return timeSlots
        }
        
        // Use a base date to combine with the time input
        //let baseDateString = "2024-08-03"// Example base date
        let baseDateString = currentDateFormatter.string(from: SelectedDate)
        let dateTimeString = baseDateString+" "+selectedTimeString
        guard let selectedTime = dateFormatter.date(from: dateTimeString) else {
            print("Invalid date string")
            return timeSlots
        }
        // Calculate the starting time (-2 hours)
        if let startTime = calendar.date(byAdding: .hour, value: -2, to: selectedTime) {
            // Generate times in 30-minute increments from startTime to endTime (+2 hours)
            for i in 0...8 {
                if let newTime = calendar.date(byAdding: .minute, value: i * 30, to: startTime) {
                    timeSlots.append(TimeSlot(time: newTime))
                }
            }
        }
        print(timeSlots)
        return timeSlots
    }

    func saveDates(dates: Set<DateComponents>) {
        // Convert DateComponents to Date
        let calendar = Calendar.current
        savedDates = dates.compactMap { calendar.date(from: $0) }.sorted()
        saveToFirebase(dates: savedDates)
    }
    
//    func updateTimeSlots() {
//        timeSlots = generateTimeSlots(from: selectedTime)
//    }
//        
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func saveToFirebase(dates: [Date]) {
        let db = Firestore.firestore()
        let dateStrings = dates.map { dateFormatter.string(from: $0) }
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        let dateMap = [uid: dateStrings]
        db.collection("spaces")
                    .document(spaceId)
                    .collection("dates")
                    .document(widget.id.uuidString)
                    .getDocument { document, error in
                        if let document = document, document.exists {
                            var existingDates = document.data()?[uid] as? [String] ?? []
                            // Update existing dates with the new selection
                            existingDates = dateStrings
                            let dateMap = [uid: existingDates]
                            db.collection("spaces")
                                .document(spaceId)
                                .collection("dates")
                                .document(widget.id.uuidString)
                                .updateData(dateMap)
                        } else {
                            // Save new dates if the document does not exist
                            let dateMap = [uid: dateStrings]
                            db.collection("spaces")
                                .document(spaceId)
                                .collection("dates")
                                .document(widget.id.uuidString)
                                .setData(dateMap)
                    }
            }
    }
    
    func loadSavedDates() {
        let db = Firestore.firestore()
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        print("User ID: \(uid)")
        print(widget.id.uuidString)
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)//widget.id.uuidString
            .getDocument {document, error in
                if let document = document {
                    self.selectedTime = document.data()?["SelectedTime"] as? String ?? ""
                    if let dateStrings = document.data()?[uid] as? [String] {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        self.savedDates = dateStrings.compactMap { dateFormatter.date(from: $0) }.sorted()
                        let calendar = Calendar.current
                        self.selectedDates = Set(self.savedDates.map { calendar.dateComponents([.calendar, .era, .year, .month, .day], from: $0) })
                    }
                } else {
                    print("Document does not exist")
                }
            }
    }
}

