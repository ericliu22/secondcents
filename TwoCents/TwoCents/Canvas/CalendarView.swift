//
//  CalendarWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 6/22/24.
//


import Foundation
import SwiftUI
import Firebase

struct CalendarView: View {
    @State var selectedDates: Set<DateComponents> = []
    @State var savedDates: [Date] = []
    var spaceId: String
    var widget: CanvasWidget
    

    var body: some View {
        VStack {
            MultiDatePicker("Select dates", selection: $selectedDates)
                .padding()
                .onChange(of: selectedDates) { oldValue, newValue in
                    saveDates(dates: selectedDates)
                 }
//            Button(action: {
//                saveDates(dates: selectedDates)
//            }) {
//                Text("Save Dates")
//            }
//            .padding()
            List(savedDates, id: \.self) { date in
                Text("\(date, formatter: dateFormatter)")
            }
            .listStyle(.plain)
        }
        .onAppear {
            loadSavedDates()
        }
//       .onChange(of: selectedDates) { oldValue, newValue in
//            saveDates(dates: selectedDates)
//        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    func saveDates(dates: Set<DateComponents>) {
        // Convert DateComponents to Date
        let calendar = Calendar.current
        savedDates = dates.compactMap { calendar.date(from: $0) }.sorted()
        saveToFirebase(dates: savedDates)
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
                            print("exists", document.exists)
                            var existingDates = document.data()?[uid] as? [String] ?? []
                            // Update existing dates with the new selection
                            existingDates = dateStrings
                            let dateMap = [uid: existingDates]
                            print(dateMap)
                            db.collection("spaces")
                                .document(spaceId)
                                .collection("dates")
                                .document(widget.id.uuidString)
                                .updateData(dateMap)
                        } else {
                            print("doesn't exist:", document?.exists)
                            // Save new dates if the document does not exist
                            let dateMap = [uid: dateStrings]
                            print(dateMap)
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
//#Preview{
//    CalendarView()
//}
