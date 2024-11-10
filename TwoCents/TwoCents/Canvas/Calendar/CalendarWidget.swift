import Foundation
import SwiftUI
import Firebase


// Model to handle date formatting
struct OptimalDate {
    var shortMonth: String?
    var longMonth: String?
    var day: String?
    var dayOfWeek: String?
    var date: Date?
    var maxTimeFrequency: Int
    
    init(from dateString: String, maxTimeFrequency: Int) {
        self.maxTimeFrequency = maxTimeFrequency
        
        guard !dateString.isEmpty else {
            print("DATE STRING IS EMPTY")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            self.date = date
            print("GABE ITCH")
            
            dateFormatter.dateFormat = "MMM"
            self.shortMonth = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "MMMM"
            self.longMonth = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "dd"
            self.day = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "EEE"
            self.dayOfWeek = dateFormatter.string(from: date)
        }
        

    }
}

// Main view for displaying the calendar widget
struct CalendarWidget: View {
    let widget: CanvasWidget
    let spaceId: String
    
    @State var viewModel: CalendarWidgetModel
    
    init(widget: CanvasWidget, spaceId: String) {
        self.widget = widget
        self.spaceId = spaceId
        self.viewModel = CalendarWidgetModel(widgetId: widget.id.uuidString, spaceId: spaceId)
    }

    var body: some View {
            VStack {
                if let date = viewModel.optimalDate {
                    if viewModel.isTodayOrTomorrow(date: date) && !viewModel.hasDatePassed(date) {
                        EventTimeView()
                    } else if viewModel.hasDatePassed(date) {
                        EventPassedView()
                    } else {
                        EventDateView()
                    }
                } else {
                    EmptyEventView(widget: widget)
                        .onAppear {
                            print("Hello")
                        }
                }
            }
            .environment(viewModel)
            .background(Color(UIColor.systemBackground))
            .frame(width: widget.width, height: widget.height)
            .cornerRadius(CORNER_RADIUS)
    }

}

// View for when there is no optimal date
struct EmptyEventView: View {
    //Drag gestures needs to be able to have no viewModel
    var widget: CanvasWidget
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(CalendarWidgetModel.self) var calendarViewModel
    
    @State private var bounce: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(calendarViewModel.eventName)
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .onAppear {
                    print("EVENT NAME: \(calendarViewModel.eventName)")
                }
            
            Spacer()
            
            Text("😔")
                .font(.system(size: 44))
                .foregroundColor(.primary)
                .overlay {
                    Text("🤘")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .offset(x: -28, y: -4)
                        .offset(y: bounce ? 3 : 0)
                        .animation(
                            Animation.easeInOut(duration: 1)
                                .repeatForever(autoreverses: true)
                        )
                        .onAppear {
                            bounce.toggle()
                        }
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 2, y: 0)
                        .rotationEffect(.degrees(-10))
                }
            
            Spacer()
            
            Button(action: {
                // Add button action here
                canvasViewModel.activeSheet = .calendar
                canvasViewModel.activeWidget = widget
            }, label: {
                Text("Party Together!")
                    .font(.caption2)
            })
            .buttonStyle(.bordered)
            .foregroundColor(Color.accentColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// View for when the date is more than 24 hours away
struct EventDateView: View {
    @State private var bounce: Bool = false
 
    @Environment(CalendarWidgetModel.self) var calendarViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(calendarViewModel.eventName)
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            if let date = calendarViewModel.optimalDate, let closestTime = calendarViewModel.optimalDate?.formatted(.dateTime.hour().minute()) {
                let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                
                Text("\(closestTime)・In \(daysDifference) day\(daysDifference != 1 ? "s" : "")")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)
            }
            
            Divider()
            Spacer()

            HStack(spacing: 3) {
                if let dayOfWeek = calendarViewModel.optimalDate?.formatted(.dateTime.weekday(.abbreviated)) {
                    Text(dayOfWeek)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.accentColor)
                }
                
                if let shortMonth = calendarViewModel.optimalDate?.formatted(.dateTime.month(.abbreviated)) {
                    Text(shortMonth)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, -8)
            
            if let day = calendarViewModel.optimalDate?.formatted(.dateTime.day()) {
                Text(day)
                    .font(.system(size: 72))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.vertical, -15)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// View for when the date is less than 24 hours away
struct EventTimeView: View {
    @State private var bounce: Bool = false
 
    @Environment(CalendarWidgetModel.self) var calendarViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(calendarViewModel.eventName)
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            if let longMonth = calendarViewModel.optimalDate?.formatted(.dateTime.month()), let day = calendarViewModel.optimalDate?.formatted(.dateTime.day()) {
                Text("\(longMonth) \(day)")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)
            }
            
            Divider()
            Spacer()
            
            if let date = calendarViewModel.optimalDate {
                Text(Calendar.current.isDateInToday(date) ? "Today" : "Tomorrow")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.accentColor)
                    .padding(.bottom, -5)
            }
            
            if let closestTime = calendarViewModel.optimalDate?.formatted(.dateTime.hour().minute()) {
                Text(closestTime)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            
           
            
            Text("\(calendarViewModel.attendees) " + (calendarViewModel.attendees == 1 ? "Attendee" : "Attendees"))
                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(.secondary)
                .padding(.top, 3)
            
            
        
        
            
            
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// View for when the event has passed
struct EventPassedView: View {
    @State private var bounce: Bool = false
    
    @Environment(CalendarWidgetModel.self) var calendarViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(calendarViewModel.eventName)
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            if let longMonth = calendarViewModel.optimalDate?.formatted(.dateTime.month()), let day = calendarViewModel.optimalDate?.formatted(.dateTime.day()) {
                Text("\(longMonth) \(day)")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
            }
            
            Text(bounce ? "🥳" : "☺️")
                .font(.system(size: 44))
                .foregroundColor(.primary)
                .onAppear {
                    startAnimation()
                }
            
            Spacer()
            
            Text("Til next time!")
                .font(.caption2)
                .foregroundColor(Color.secondary)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func startAnimation() {
        bounce = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let animation = Animation.easeInOut(duration: 1)
                .delay(2.0)
                .repeatForever(autoreverses: true)

            withAnimation(animation) {
                bounce.toggle()
            }
        }
    }
}


func deleteCalendar(spaceId: String, calendarId: String) {
    db.collection("spaces")
        .document(spaceId)
        .collection("calendar")
        .document(calendarId)
        .delete()
}
