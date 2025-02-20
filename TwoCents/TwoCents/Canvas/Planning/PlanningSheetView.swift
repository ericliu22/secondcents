import SwiftUI
import UIKit
struct PlanningCalendarView: View {
    // The base month is the month when the view loads.
    private let baseDate: Date = Calendar.current.startOfDay(for: Date())
    
    @State private var showDailySchedule = false
    @State private var dateForSchedule: Date?
    
    // The currently displayed month. (This can change as the user navigates.)
    @State private var displayedDate: Date = Calendar.current.startOfDay(for: Date())
    
    private let calendar = Calendar.current
    
    // Force week columns to start with Sunday.
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            // MARK: - Header with Month Navigation
            HStack {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                }
                .disabled(isBaseMonth()) // Prevent going back before the base month
                
                Spacer()
                
                Text(monthYearString(for: displayedDate))
                    .font(.headline)
                
                Spacer()
                
                Button(action: goForward) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // MARK: - Weekday Labels (Sun - Sat)
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Calendar Grid
            let days = generateDaysForMonth(displayedDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        let date = dateFrom(day: day, month: displayedDate)
                        
                        // Simply show the sheet when tapped — no selection tracking.
                        Button(action: {
                            dateForSchedule = date
                            showDailySchedule = true
                        }) {
                            Text("\(day)")
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Color.gray)
                                .cornerRadius(5)
                                .foregroundColor(.white)
                        }
                        
                    } else {
                        // Empty cell for alignment
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
            .padding()
        }
        // Present the sheet when showDailySchedule == true
        .sheet(isPresented: $showDailySchedule) {
            if let date = dateForSchedule {
                AvailabilityTimePicker()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Generates an array representing the grid cells for the current month.
    /// The array contains optional Int values: `nil` for blank cells and the day number for valid dates.
    func generateDaysForMonth(_ date: Date) -> [Int?] {
        guard let dayRange = calendar.range(of: .day, in: .month, for: date) else { return [] }
        let days = Array(dayRange)
        
        // Determine the weekday (1 = Sunday, 2 = Monday, …) of the first day of the month.
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = 1
        let firstDayDate = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayDate)
        let offset = firstWeekday - 1  // If Sunday, offset is 0.
        
        // Create an array with offset nil values followed by the actual days.
        let blanks = Array<Int?>(repeating: nil, count: offset)
        let dayNumbers = days.map { Optional($0) }
        return blanks + dayNumbers
    }
    
    /// Returns a full Date for a given day number in the displayed month.
    func dateFrom(day: Int, month: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
    
    /// Formats the displayed month and year as "Month yyyy".
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    /// Advances the displayed month by 1.
    func goForward() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedDate) {
            displayedDate = nextMonth
        }
    }
    
    /// Goes back one month, but only if the result is not before the base month.
    func goBack() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedDate),
           calendar.compare(previousMonth, to: baseDate, toGranularity: .month) != .orderedAscending {
            displayedDate = previousMonth
        }
    }
    
    /// Returns true if the displayed month is the same as the base month.
    func isBaseMonth() -> Bool {
        return calendar.isDate(displayedDate, equalTo: baseDate, toGranularity: .month)
    }
}



struct CustomPlanningCalendarView_Previews: PreviewProvider {
    static var previews: some View {
//        AvailabilityTimePicker(date: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 17)) ?? Date())
        PlanningCalendarView()
    }
}

