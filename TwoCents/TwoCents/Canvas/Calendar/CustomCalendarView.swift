import SwiftUI
import Foundation
import FirebaseFirestore

struct CustomCalendarView: View {
    @State private var month: String = ""
    @State private var year: String = ""
    @State private var days: [String] = []
    @State private var currentDate = Date()
    @State private var selectedDates: [String] = []
    var spaceId: String
    var widget: CanvasWidget
    
    let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private let fixedColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                Spacer()
                Text("\(month) \(year)")
                    .font(.largeTitle)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            .padding()
            
            // DAYS OF WEEK LABEL
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .frame(maxWidth: .infinity)
            
            // DATE
            LazyVGrid(columns: fixedColumns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Button {
                        if !day.isEmpty {
                            if let index = selectedDates.firstIndex(of: day) {
                                selectedDates.remove(at: index)
                                print("Removed date: \(day). Selected dates: \(selectedDates)")
                            } else {
                                selectedDates.append(day)
                                print("Added date: \(day). Selected dates: \(selectedDates)")
                            }
                        }
                    } label: {
                        Text(day)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(10)
                            .background(selectedDates.contains(day) ? Color.blue.opacity(0.5) : Color.clear)
                            .cornerRadius(8)
                            .buttonStyle(.bordered)
                    }
                }
            }
        }
        .onAppear {
            updateCalendar()
        }
    }

    func updateCalendar() {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        self.month = dateFormatter.string(from: currentDate)
        dateFormatter.dateFormat = "yyyy"
        self.year = dateFormatter.string(from: currentDate)

        // Get the day of the week for the first day of the current month
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        dateFormatter.dateFormat = "EEEE"  // For full day of the week name
        let firstDayOfWeek = dateFormatter.string(from: firstDayOfMonth)

        // Determine the starting index based on the first day of the week
        let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let startingIndex = weekDays.firstIndex(of: firstDayOfWeek)!

        // Get the range of days in the current month
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        
        // Create an array with empty strings for days before the start of the month
        var daysArray = Array(repeating: "", count: startingIndex)
        daysArray.append(contentsOf: (1...daysInMonth).map { "\($0)" })
        
        // Add empty strings to fill the last row
        let extraSpaces = 7 - (daysArray.count % 7)
        if extraSpaces < 7 {
            daysArray.append(contentsOf: Array(repeating: "", count: extraSpaces))
        }

        self.days = daysArray
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }
}

//struct CalendarViewTest_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomCalendarView()
//    }
//}
