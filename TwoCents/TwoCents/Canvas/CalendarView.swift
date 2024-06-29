//
//  eventWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 6/22/24.
//

//updated

import Foundation
import SwiftUI
import Firebase

struct CalendarView: View {
    @State private var selectedDates: Set<DateComponents> = []
    @State private var savedDates: [Date] = []

    var body: some View {
        VStack {
            // Your MultiDatePicker implementation
            MultiDatePicker("Select dates", selection: $selectedDates)
                .padding()
            
            Button(action: {
                saveDates(dates: selectedDates)
            }) {
                Text("Save Dates")
            }
            .padding()
            
            List(savedDates, id: \.self) { date in
                Text("\(date, formatter: dateFormatter)")
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
    
    func saveDates(dates: Set<DateComponents>) {
        // Convert DateComponents to Date
        let calendar = Calendar.current
        savedDates = dates.compactMap { calendar.date(from: $0) }
        saveToFirebase(dates: savedDates)
    }
    
    func saveToFirebase(dates: [Date]) {
        let db = Firestore.firestore()
        let dateStrings = dates.map { dateFormatter.string(from: $0) }
        print(dateStrings)
    }
    
    func loadSavedDates() {
        let db = Firestore.firestore()
    }
}

#Preview{
    CalendarView()
}
