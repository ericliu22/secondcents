//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import Firebase

struct CalendarWidget: WidgetView {
    
//    @State private var isPresented: Bool = false
    let widget: CanvasWidget // Assuming CanvasWidget is a defined type
//    @StateObject private var viewModel = TextWidgetViewModel()
    @State var EarliestFoundDate: String = ""
    
    @State private var userColor: Color = .gray
    var spaceId: String
    
    var body: some View {
        
        ZStack{
            
            Color(UIColor.tertiarySystemFill)
            
            
            VStack{
               
                Color.red
                Text(EarliestFoundDate)
            }
            .background(Color.white)
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .cornerRadius(CORNER_RADIUS)
        }.onAppear(perform: FindCommonDate)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    func FindCommonDate() {
            let db = Firestore.firestore()
            let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
            print("User ID: \(uid)")
            print(widget.id.uuidString)

            db.collection("spaces")
                .document(spaceId)
                .collection("dates")
                .document(widget.id.uuidString)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot, document.exists else {
                        print("Document does not exist")
                        return
                    }
                    
                    if let data = document.data() {
                        var allDates: [Date] = []
                        for key in data.keys {
                            if let dateStrings = data[key] as? [String] {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateStyle = .medium
                                for dateString in dateStrings {
                                    if let date = dateFormatter.date(from: dateString) {
                                        allDates.append(date)
                                    }
                                }
                            }
                        }
                        if let mostCommonDate = self.findMostCommonDate(dates: allDates) {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            self.EarliestFoundDate = dateFormatter.string(from: mostCommonDate)
                            print("Most Common Date: \(self.EarliestFoundDate)")
                        }
                    }
                }
        }

    func findMostCommonDate(dates: [Date]) -> Date? {
            var dateCounts: [Date: Int] = [:]
            for date in dates {
                if let count = dateCounts[date] {
                    dateCounts[date] = count + 1
                } else {
                    dateCounts[date] = 1
                }
            }
            return dateCounts.max { (a, b) in
                if a.value == b.value {
                    return a.key > b.key // This ensures the earliest date is chosen in the event of a tie
                } else {
                    return a.value < b.value
                }
            }?.key
    }
}
