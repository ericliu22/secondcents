//
//  AppleCalendarExperiments.swift
//  TwoCents
//
//  Created by Joshua Shen on 2/17/25.
//

import SwiftUI
import EventKit

struct AppleEventView: View {
    @State private var events: [EKEvent] = []
    private let eventStore = EKEventStore()

    var body: some View {
        VStack {
            Button("Request Calendar Access") {
                requestAccess()
            }
            .padding()

            List(events, id: \.eventIdentifier) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.startDate, style: .date)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            fetchEvents()
        }
    }

    // Request permission to access calendar
    private func requestAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                fetchEvents()
            } else {
                print("Access Denied")
            }
        }
    }

    // Fetch upcoming events from the calendar
    private func fetchEvents() {
        let calendars = eventStore.calendars(for: .event)
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)

        DispatchQueue.main.async {
            self.events = eventStore.events(matching: predicate)
        }
    }
}


struct OpenAppleCalendar_Previews: PreviewProvider {
    static var previews: some View {
//        AvailabilityTimePicker(date: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 17)) ?? Date())
        AppleEventView()
    }
}
