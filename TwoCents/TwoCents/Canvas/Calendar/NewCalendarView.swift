//
//  NewCalendarView.swift
//  TwoCents
//
//  Created by Joshua Shen on 8/15/24.
//

import SwiftUI
import Foundation
import Firebase

struct NewCalendarView: View {
    
    @State private var spaceId: String
    @State private var showingView: Bool = false
    
    @State private var userColor: Color = Color.gray
    
    @Binding private var closeNewWidgetview: Bool
    init(spaceId: String, closeNewWidgetview: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetview = closeNewWidgetview
    }
    
    
    @State private var navigateToNextPage = false
    @State private var name: String = ""
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    @State private var AMorPM: String = ""
    
    // New state for managing the date picker
    @State private var isLabelVisible: Bool = false
    @State private var finalDate: Date = Date()  // State to store selected date
    @State private var isDatePickerPresented: Bool = false // Controls DatePicker popup
    @State private var createdWidgetId: String = ""
    
    
    var body: some View {
        NavigationView {
            VStack() {
                Text("Are we Going Outside⁉️ 😱")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                TextField("What we doing? 🤔", text: $name)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                Text("What time do you prefer?")
                    .padding()
                // Custom time picker
                CustomTimePicker(selectedHour: $selectedHour, selectedMinute: $selectedMinute, selectedAMorPM: $AMorPM)
                
                // Toggle button
                Toggle(isOn: $isLabelVisible) {
                    Text("Let's hangout before ___!")
                }
                .padding()
                
                // Display the label and handle tap to show DatePicker in a popup
                if isLabelVisible {
                    Text("Selected Date: \(formattedDate(finalDate))")
                        .padding()
                        .foregroundColor(.blue)
                        .onTapGesture {
                            isDatePickerPresented.toggle()
                        }
                        .popover(isPresented: $isDatePickerPresented, arrowEdge: .bottom) {
                            VStack {
                                DatePicker("Select a Date", selection: $finalDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.9)//this line v important
                                Button("Done") {
                                    isDatePickerPresented = false
                                }
                                .padding()
                            }
                            .presentationCompactAdaptation(.popover)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                }
                Button(action: {
                    print("clicked")
                    let userId = "fOBAypBOWBVkpHEft3V3Dq9JJgX2"
                    let newEvent = CanvasWidget(x: 0, y: 0, borderColor: Color.accentColor, userId: userId, media: .calendar)
                    SpaceManager.shared.uploadWidget(spaceId: spaceId, widget: newEvent)
                    self.createdWidgetId = newEvent.id.uuidString
                    print("newID: \(createdWidgetId)")
                    name = ""
                    saveValues()
                    closeNewWidgetview = true
                    navigateToNextPage =  true
                }, label: {
                    Text("Pick Some Dates")
                })
            }
        }
        //Ideally: Get "widget" and then pass to CalendarView
//        NavigationLink(destination: CalendarView(spaceId: spaceId, widgetId: createdWidgetId), isActive: $navigateToNextPage) {
//                   EmptyView()
//       }
    }
    
    // Helper function to format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func saveValues() {
        let db = Firestore.firestore()
        let userId = "fOBAypBOWBVkpHEft3V3Dq9JJgX2"
        db.collection("Spaces")
            .document(spaceId)
            .collection("dates")
            .document(createdWidgetId)
            .setData(["name": name, "preferredTime": "\(selectedHour):\(selectedMinute) \(AMorPM)", "creator": userId])
            print("dates saved?")
    }
}

struct CustomTimePicker: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedAMorPM: String
    
    // Hours and minutes arrays
    private var hours: [Int] {
        Array(1..<13)
    }
    
    private var minutes: [Int] {
        Array(stride(from: 0, to: 60, by: 30))
    }
    
    // Computed property to handle circular hour selection
    private var circularHours: [Int] {
        Array(1...12)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Picker(selection: Binding(
                    get: { self.selectedHour },
                    set: { newValue in
                        if newValue > 12 {
                            self.selectedHour = 1
                        } else if newValue < 1 {
                            self.selectedHour = 12
                        } else {
                            self.selectedHour = newValue
                        }
                    }
                ), label: Text("Hour")) {
                    ForEach(circularHours, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
                .clipped()
                
                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                Picker(selection: $selectedMinute, label: Text("Minute")) {
                    ForEach(minutes, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
                .clipped()
                
                Text(":")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                Picker(selection: $selectedAMorPM, label: Text("AM or PM")) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
                .clipped()
            }
        }
    }
}


#Preview {
    NavigationStack{
        NewCalendarView(spaceId: "E97EAD99-254E-402E-A2C1-491CBC9829FE", closeNewWidgetview: .constant(false))
    }
}
