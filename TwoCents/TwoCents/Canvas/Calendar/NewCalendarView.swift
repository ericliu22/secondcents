import Firebase
import Foundation
import SwiftUI

struct NewCalendarView: View {

    @Binding var closeNewWidgetView: Bool
    @Bindable var viewModel: NewCalendarViewModel
    @Environment(AppModel.self) var appModel

    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.viewModel = NewCalendarViewModel(spaceId: spaceId)
        //The incoming closeNewWidgetview is lowercase v
        self._closeNewWidgetView = closeNewWidgetview
    }

    var body: some View {

        VStack(alignment: .center, spacing: 0) {
            Text("Eventful Event")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            Text("6:00 PM・In 4 days")
                .font(.caption)
                .foregroundColor(Color.secondary)
                .fontWeight(.semibold)
                .padding(.bottom, 3)

            Divider()
            Spacer()

            HStack(spacing: 3) {

                Text("Tue")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.accentColor)

                Text("Aug")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

            }
            .padding(.top, -8)

            Text("18")
                .font(.system(size: 84))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.vertical, -15)

        }
        .padding(20)

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        .background(Color(UIColor.systemBackground))

        .onTapGesture {
            viewModel.showingView.toggle()
            print("tapped")
        }
        .fullScreenCover(isPresented: $viewModel.showingView) {
            NavigationStack {
                List {
                    VStack {
                        TextField("Event Name", text: $viewModel.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(appModel.loadedColor)

                        Divider()
                            .padding(.vertical)

                        Text("Preferred Time")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        CustomTimePicker()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .environment(viewModel)

                        Divider()
                            .padding(.vertical)

                        Toggle(isOn: $viewModel.isDatePickerVisible) {
                            Text("End Date")
                        }

                        if viewModel.isDatePickerVisible {
                            DatePicker(
                                "Select a Date", selection: $viewModel.endDate,
                                in: Date()..., displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider()
                            .padding(.vertical)

                        Button(
                            action: {
                                viewModel.createWidget()
                                closeNewWidgetView = true
                            },
                            label: {
                                Text("Create Widget")
                                    .font(.headline)
                                    .frame(height: 55)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .buttonStyle(.bordered)
                        .frame(height: 55)
                        .cornerRadius(10)
                        .disabled(viewModel.name.isEmpty)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Create Event 🗓️")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                viewModel.showingView = false
                            },
                            label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.label))
                            })
                    }
                }
            }
        }
    }

}

struct CustomTimePicker: View {
    @Environment(NewCalendarViewModel.self) var viewModel

    private var hours: [Int] {
        Array(1..<13)
    }

    private var minutes: [Int] {
        Array(stride(from: 0, to: 60, by: 30))
    }

    private var circularHours: [Int] {
        Array(1...12)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            HStack(spacing: 0) {
                Picker(selection: $viewModel.selectedHour, label: Text("Hour"))
                {
                    ForEach(circularHours, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .onAppear {
                    // Ensure the default value is selected
                    if !circularHours.contains(viewModel.selectedHour) {
                        viewModel.selectedHour = 6
                    }
                }

                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)

                Picker(
                    selection: $viewModel.selectedMinute, label: Text("Minute")
                ) {
                    ForEach(minutes, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .onAppear {
                    // Ensure the default value is selected
                    if !minutes.contains(viewModel.selectedMinute) {
                        viewModel.selectedMinute = 0
                    }
                }

                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)

                Picker(selection: $viewModel.AMorPM, label: Text("AM or PM")) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .onAppear {
                    // Ensure the default value is selected
                    if viewModel.AMorPM
                        != "AM"
                        && viewModel.AMorPM
                            != "PM"
                    {
                        viewModel.AMorPM = "PM"
                    }
                }
            }
        }
    }
}

/*
#Preview {
    NavigationStack {
        NewCalendarView(viewModel.spaceId: "E97EAD99-254E-402E-A2C1-491CBC9829FE", closeNewWidgetview: .constant(false))
    }
}
*/
