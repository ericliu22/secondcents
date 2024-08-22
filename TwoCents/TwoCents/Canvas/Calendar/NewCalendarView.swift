import SwiftUI
import Foundation
import Firebase

struct NewCalendarView: View {
    
    @State private var spaceId: String
    @State private var showingView: Bool = false
    @State private var userColor: Color = Color.gray
    @Binding private var closeNewWidgetview: Bool
    @State private var navigateToNextPage = false
    @State private var name: String = ""
    @State private var selectedHour: Int = 6   // Default hour set to 6
    @State private var selectedMinute: Int = 0 // Default minute set to 0
    @State private var AMorPM: String = "PM"  // Default AM/PM set to PM
    @State private var isLabelVisible: Bool = false
    @State private var finalDate: Date = Date()
    @State private var isDatePickerPresented: Bool = false
    @State private var createdWidgetId: String = ""

    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetview = closeNewWidgetview
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("26")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(userColor)
                Text("Votes")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundStyle(userColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .background(Color(UIColor.systemBackground))
        .frame(width: .infinity, height: .infinity)
        .onTapGesture { showingView.toggle() }
        .fullScreenCover(isPresented: $showingView) {
            NavigationStack {
                List {
                    VStack {
                        TextField("Event Name", text: $name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(userColor)
                        
                        Divider()
                            .padding(.vertical)
                        
                        Text("Preferred Time")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTimePicker(selectedHour: $selectedHour, selectedMinute: $selectedMinute, selectedAMorPM: $AMorPM)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                        
                        Divider()
                            .padding(.vertical)
                        
                        Toggle(isOn: $isLabelVisible) {
                            Text("End Date")
                        }
                        
                        if isLabelVisible {
                            DatePicker("Select a Date", selection: $finalDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        Button(action: {
                            let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid
                            let newWidget = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId ?? "", media: .calendar)
                            SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newWidget)
                            self.createdWidgetId = newWidget.id.uuidString
                            saveCalendar(userId: userId ?? "")
                            closeNewWidgetview = true
                        }, label: {
                            Text("Create Widget")
                                .font(.headline)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.bordered)
                        .frame(height: 55)
                        .cornerRadius(10)
                        .disabled(name.isEmpty)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Create Event 🗓️")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingView = false
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.label))
                        })
                    }
                }
            }
        }
        .task {
            userColor = try! await Color.fromString(name: UserManager.shared.getUser(userId: AuthenticationManager.shared.getAuthenticatedUser().uid).userColor ?? "")
        }
    }
    
    private func formattedTime() -> String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(AMorPM)"
    }
    
    func saveCalendar(userId: String) {
        let db = Firestore.firestore()
        do {
            try db.collection("spaces")
                .document(spaceId)
                .collection("calendar")
                .document(createdWidgetId)
                .setData(["name": name,
                          "preferredTime": formattedTime(),
                          "creator": userId])
        } catch {
            print("Error uploading calendar")
        }
    }
}

struct CustomTimePicker: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedAMorPM: String
    
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
        VStack {
            HStack(spacing: 0) {
                Picker(selection: $selectedHour, label: Text("Hour")) {
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
                    if !circularHours.contains(selectedHour) {
                        selectedHour = 6
                    }
                }
                
                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                Picker(selection: $selectedMinute, label: Text("Minute")) {
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
                    if !minutes.contains(selectedMinute) {
                        selectedMinute = 0
                    }
                }
                
                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                Picker(selection: $selectedAMorPM, label: Text("AM or PM")) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .onAppear {
                    // Ensure the default value is selected
                    if selectedAMorPM != "AM" && selectedAMorPM != "PM" {
                        selectedAMorPM = "PM"
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewCalendarView(spaceId: "E97EAD99-254E-402E-A2C1-491CBC9829FE", closeNewWidgetview: .constant(false))
    }
}
