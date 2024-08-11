import Foundation
import SwiftUI
import Firebase
import EventKit

struct CalendarWidget: WidgetView {
    let widget: CanvasWidget
    @State var EarliestFoundDate: String = ""
    @State var idsWithoutDate: [String] = []
    @State private var userColor: Color = .gray
    var spaceId: String
    
    var body: some View {
        ZStack {
            Color(UIColor.tertiarySystemFill)
            VStack {
                Color.red
                Text(EarliestFoundDate)
                List(idsWithoutDate, id: \.self) { id in
                    Text(id)
                }
            }
            .background(Color.white)
            .frame(width: TILE_SIZE, height: TILE_SIZE)
            .cornerRadius(CORNER_RADIUS)
        }
        .onAppear(perform: FindCommonDate)
    }
    
    private let dateFormatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
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
                    print("Document data: \(data)") // Debugging output
                    
                    var allDates: [Date] = []
                    for (_, dateStrings) in data {
                        if let dateStringsArray = dateStrings as? [String] {
                            for dateString in dateStringsArray {
                                if let date = dateFormatterWithTime.date(from: dateString) {
                                    allDates.append(date)
                                } else {
                                    print("Failed to parse date string: \(dateString)") // Debugging output
                                }
                            }
                        } else {
                            print("Failed to cast user data: \(dateStrings)") // Debugging output
                        }
                    }
                    
                    print("All parsed dates: \(allDates)") // Debugging output
                    
                    if let mostCommonDate = self.findMostCommonDate(dates: allDates) {
                        self.EarliestFoundDate = dateFormatterWithTime.string(from: mostCommonDate)
                        print("Most Common Date: \(self.EarliestFoundDate)")
                        self.findIdsWithoutDate(mostCommonDate: mostCommonDate)
                    } else {
                        print("No common date found") // Debugging output
                    }
                } else {
                    print("Failed to retrieve document data: \(error?.localizedDescription ?? "Unknown error")") // Debugging output
                }
            }
    }
    
    func findMostCommonDate(dates: [Date]) -> Date? {
        var dateCounts: [Date: Int] = [:]
        for date in dates {
            dateCounts[date, default: 0] += 1
        }
        let sortedDates = dateCounts.sorted { a, b in
            if a.value == b.value {
                return a.key < b.key // Ensures the earliest date is chosen in the event of a tie
            } else {
                return a.value > b.value
            }
        }
        print("Sorted date counts: \(sortedDates)") // Debugging output
        return sortedDates.first?.key
    }
    
    func findIdsWithoutDate(mostCommonDate: Date) {
        let db = Firestore.firestore()
        let mostCommonDateString = dateFormatterWithTime.string(from: mostCommonDate)
        
        db.collection("spaces")
            .document(spaceId)
            .collection("dates")
            .document(widget.id.uuidString)
            .getDocument { documentSnapshot, error in
                guard let document = documentSnapshot, document.exists else {
                    print("Document does not exist")
                    return
                }

                if let data = document.data() {
                    var newIdsWithoutDate = [String]()
                    
                    for (uid, dateStrings) in data {
                        if let userDates = dateStrings as? [String] {
                            if !userDates.contains(mostCommonDateString) {
                                newIdsWithoutDate.append(uid)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.idsWithoutDate = newIdsWithoutDate
                    }
                }
            }
    }
}
