import Firebase
//
//  NewCalendarViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/11/10.
//
import SwiftUI

@MainActor @Observable
class NewCalendarViewModel {

    var name: String = ""
    var selectedHour: Int = 6  // Default hour set to 6
    var selectedMinute: Int = 0  // Default minute set to 0
    var AMorPM: String = "PM"  // Default AM/PM set to PM
    var isLabelVisible: Bool = false
    var endDate: Date = Date()
    var isDatePickerVisible: Bool = false
    var createdWidgetId: String = ""
    var showingView: Bool = false
    let spaceId: String

    init(spaceId: String) {
        self.spaceId = spaceId
    }

    func formattedTime() -> String {
        return
            "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(AMorPM)"
    }

    func generateDate() -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents(
            [.year, .month, .day], from: Date())  // Get the current date's year, month, and day
        var formattedHour: Int = selectedHour % 12
        if AMorPM == "PM" {
            formattedHour += 12
        }
        components.hour = formattedHour
        components.minute = selectedMinute
        components.second = 0

        return calendar.date(from: components)
    }

    func saveCalendar(userId: String) {
        let db = Firestore.firestore()

        guard let date = generateDate() else {
            print("NewCalendarViewModel saveCalendar: Failed to generate date")
            return
        }

        db.collection("spaces")
            .document(spaceId)
            .collection("calendar")
            .document(createdWidgetId)
            .setData([
                "name": name,
                "preferredTime": formattedTime(),
                "creator": userId,
                "endDate": isDatePickerVisible ? endDate : nil,
            ])
    }

    func createWidget() {
        let userId = try? AuthenticationManager.shared.getAuthenticatedUser()
            .uid
        let newWidget = CanvasWidget(
            x: 0, y: 0, borderColor: Color.accentColor, userId: userId ?? "",
            media: .calendar)
        SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newWidget)
        createdWidgetId = newWidget.id.uuidString
        saveCalendar(userId: userId ?? "")
    }
}
