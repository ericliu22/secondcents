import Firebase
import SwiftUI

struct CalendarWidgetSheetView: View {
    let widgetId: String
    let spaceId: String

    @State private var localChosenDates: [Date: Set<Date>] = [:]
    @State private var previousSelectedDates: Set<DateComponents> = []
    @State private var currentlySelectedDate: Date? = nil
    @State private var preferredTime: Date? = nil
    @State private var isDatePickerEnabled: Bool = false  // Control the enabled/disabled state of the date picker

    @State var viewModel: CalendarWidgetModel
    @Environment(\.dismiss) var dismissScreen

    init(widgetId: String, spaceId: String) {
        self.widgetId = widgetId
        self.spaceId = spaceId
        self.viewModel = CalendarWidgetModel(
            widgetId: widgetId, spaceId: spaceId)
    }

    // Compute the current date and the bounds
    private var startDate: Date {
        let now = Date()
        let calendar = Calendar.current

        if let preferredTime = preferredTime {
            let preferredTimeToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: preferredTime),
                minute: calendar.component(.minute, from: preferredTime),
                second: 0,
                of: now)!

            let cutoffTime = calendar.date(
                byAdding: .hour,
                value: 2,
                to: preferredTimeToday
            )!

            if now > cutoffTime {
                return calendar.startOfDay(
                    for: calendar.date(byAdding: .day, value: 1, to: now)!)
            }
        }

        return calendar.startOfDay(for: now)
    }

    @State private var bounds: Range<Date> =
        Calendar.current.startOfDay(for: Date())..<Calendar.current.date(
            byAdding: .year, value: 1, to: Date())!

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    @ViewBuilder
    func incompleteView() -> some View {
        if isDatePickerEnabled {
            Text("Select Availability for Start Time")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 300)

            Spacer()
        } else {
            ProgressView()
        }
    }

    func dateButton(timeSlot: Date, selectedDate: Date) -> some View {
        let isChosen =
            localChosenDates[selectedDate]?.contains(timeSlot) == true
        let buttonColor: Color =
            viewModel.hasDatePassed(timeSlot)
            ? .gray : (isChosen ? .green : .red)
        let userCount = viewModel.dateFrequencies[timeSlot, default: 0]  // Get the user count
        return Button {
            viewModel.toggleTimeSelection(timeSlot)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            VStack {
                Text(
                    timeSlot.formatted(
                        .dateTime.hour().minute().locale(
                            Locale(identifier: "en_US")))
                )
                .fontWeight(.semibold)
                .foregroundColor(buttonColor)
                .frame(maxWidth: .infinity)

                if viewModel.sameTime(timeSlot, viewModel.proposedDate) {
                    Text("Proposed Time")
                        .font(.caption)

                        .foregroundColor(buttonColor)
                        .frame(maxWidth: .infinity)
                }

                Text(
                    "\(viewModel.dateFrequencies[timeSlot, default: 0]) Selected"
                )  // Display the user count
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 100)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.hasDatePassed(timeSlot))  // Disable the button if the time slot is in the past
        .tint(buttonColor)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            ScrollView {
                VStack {
                    MultiDatePicker(
                        "Select Dates", selection: $viewModel.selectedDates,
                        in: bounds
                    )
                    .disabled(!isDatePickerEnabled)  // Disable the date picker if not enabled
                    .onChange(of: viewModel.selectedDates) {
                        viewModel.handleDateSelection()
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    if let selectedDate = currentlySelectedDate {
                        VStack {
                            LazyVGrid(columns: columns, spacing: nil) {
                                ForEach(
                                    viewModel.timeSlots(for: selectedDate),
                                    id: \.self
                                ) { timeSlot in
                                    dateButton(
                                        timeSlot: timeSlot,
                                        selectedDate: selectedDate)
                                }
                            }

                            .padding(.horizontal)
                        }
                    } else {
                        incompleteView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismissScreen()
                        }
                    }
                }
                .onDisappear { viewModel.saveDates() }
            }
            .navigationTitle(
                currentlySelectedDate?.formatted(.dateTime.month())
                    ?? viewModel.eventName
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
