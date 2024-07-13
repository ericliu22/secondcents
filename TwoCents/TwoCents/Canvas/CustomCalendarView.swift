//
//  CalendarViewTest.swift
//  TwoCents
//
//  Created by Joshua Shen on 7/13/24.
//

import Foundation
import SwiftUI

struct CalendarViewTest: View {
    @State private var month: String = ""
    @State private var day: String = ""
    @State private var year: String = ""
    
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
            Text("\(month) \(year)")
            HStack{
                Text("SUN")
                Text("MON")
                Text("TUE")
                Text("WED")
                Text("THU")
                Text("FRI")
                Text("SAT")
            }
            LazyVGrid(columns: fixedColumns, content: {
            })
        }
        .onAppear {
            getCurrentDate()
        }
    }
    
    func getCurrentDate() {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM" // For full month name, use "MM" for numerical month
        self.month = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd"
        self.day = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        self.year = dateFormatter.string(from: date)
    }
}

struct CalendarViewTest_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewTest()
    }
}
