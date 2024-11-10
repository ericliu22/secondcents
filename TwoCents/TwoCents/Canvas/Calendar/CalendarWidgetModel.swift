//
//  CalendarWidgetModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/10/27.
//

import Firebase
import SwiftUI

@MainActor @Observable
class CalendarWidgetModel {
    let widgetId: String
    let spaceId: String
    var userId: String?
    var space: DBSpace?

    var selectedDates: Set<DateComponents> = []
    var eventName: String = ""
    var optimalDate: Date?
    var attendees: Int?
    var dates: [String: [Date]] = [:]
    var proposedDate: Date = Date()
    var dateFrequencies: [Date: Int] = [:]

    init(widgetId : String, spaceId: String) {
        self.widgetId = widgetId
        self.spaceId = spaceId
        Task {
            guard
                let space = try? await SpaceManager.shared.getSpace(
                    spaceId: spaceId)
            else {
                print("Couldn't get space")
                return
            }
            //This is dogshit but perhaps in this case it might be alright
            self.userId = try? AuthenticationManager.shared
                .getAuthenticatedUser().uid
            self.space = space
            await initialFetch()
        }
    }

    let dateFormatterMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    func initialFetch() async {
        guard
            let document = try? await Firestore.firestore()
                .collection("spaces")
                .document(spaceId)
                .collection("calendar")
                .document(widgetId)
                .getDocument()
        else {
            print("CalendarWidgetModel: Failed fetch document")
            return
        }
        guard let name = document.get("name") as? String else {
            print("CalendarWidgetModel: Failed to fetch event name")
            return
        }
        eventName = name
        print("SET EVENT NAME")
        guard let timestamp = document.get("proposedTime") as? Timestamp else {
            print("CalendarWidgetModel: Failed to fetch proposed time")
            return
        }
        proposedDate = timestamp.dateValue()
    }

    func attachListener() {
        Firestore.firestore()
            .collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)
            .addSnapshotListener({ [weak self] querySnapshot, error in
                guard let self = self else {
                    print("CalendarWidgetModel: weak self")
                    return
                }
                guard let document = querySnapshot else {
                    print(
                        "CalendarWidgetModel: Error fetching calendar snapshot")
                    return
                }
                guard let data = document.data() else {
                    print("CalendarWidgetModel: Couldn't get space")
                    return
                }

                for member in data.keys {
                    guard let timestamps = data[member] as? [Timestamp] else {
                        print("CalendarWidgetModel: Failed to get as timestamp")
                        continue
                    }
                    for timestamp in timestamps {
                        if dates[member] != nil {
                            dates[member]!.append(timestamp.dateValue())
                        } else {
                            dates[member] = [timestamp.dateValue()]
                        }
                    }
                }

                findOptimalDate()
            })
    }

    func getDateFrequencies() -> [Date: Int] {
        var dateFrequencies: [Date: Int] = [:]
        for dateArray in dates.values {
            for date in dateArray {
                if dateFrequencies.contains(where: { key, value in
                    return key == date
                }) {
                    dateFrequencies[date]! += 1
                } else {
                    dateFrequencies[date] = 1
                }
            }
        }
        return dateFrequencies
    }

    func findOptimalDate() {
        dateFrequencies = getDateFrequencies()
        guard
            let mostCommonDate: Date = dateFrequencies.max(by: {
                $0.value > $1.value
            })?.key
        else {
            print("CalendarWidgetModel: Couldn't find optimal date")
            return
        }
        optimalDate = mostCommonDate
        attendees = dateFrequencies[mostCommonDate]
    }

    func isTodayOrTomorrow(date: Date) -> Bool {
        let TOMORROW_IN_SECONDS: Double = 86400
        return date.timeIntervalSinceNow < TOMORROW_IN_SECONDS
    }

    func hasDatePassed(_ date: Date) -> Bool {
        return date.timeIntervalSinceNow < 0
    }

    func uploadDate(date: Date, userId: String) {
        let uploadTimestamp = Timestamp(date: date)
        Firestore.firestore()
            .collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)
            .updateData([userId: FieldValue.arrayUnion([uploadTimestamp])])
    }

    func removeDate(userId: String, date: Date) {
        let uploadTimestamp = Timestamp(date: date)
        Firestore.firestore()
            .collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(widgetId)
            .updateData([userId: FieldValue.arrayRemove([uploadTimestamp])])
    }

    //@TODO: implement
    func saveDates() {

    }

    //@TODO: implement
    func handleDateSelection() {

    }

    func toggleTimeSelection(_ date: Date) {

    }

    func sameTime(_ date1: Date, _ date2: Date) -> Bool {
        return date1.formatted(date: .omitted, time: .complete)
            == date2.formatted(date: .omitted, time: .complete)
    }

    func timeSlots(for date: Date) -> [Date] {
        var currentDate = date
        currentDate.addTimeInterval(-2 * 3600)
        var dates: [Date] = []

        for i in 0..<10 {
            dates.append(currentDate)
            currentDate.addTimeInterval(1800)
        }
        return dates
    }
}
