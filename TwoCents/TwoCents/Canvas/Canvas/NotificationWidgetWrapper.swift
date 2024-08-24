//
//  NotificationWidgetWrapper.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/23.
//

import Foundation
import SwiftUI

struct NotificationWidgetWrapper : View {
    
    @State var loadedColor: Color = .gray
    let widgetUserId: String
    private let FOREGROUND_COLOR: Color = .white
    private let SIZE = 20.0
    private let x = 20.0
    private let y = 12.0
    
    init(widgetUserId: String) {
        self.widgetUserId = widgetUserId
    }
    
    func loadColor(widgetUserId: String) async {
        guard let user = try? await db.collection("users").document(widgetUserId).getDocument(as: DBUser.self) else {
            print("NotificationWidgetWrapper: failed to get user color")
            return
        }
        guard let colorName = user.userColor else {
            return
        }
        loadedColor = Color.fromString(name: colorName)
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(loadedColor)
                .frame(width: SIZE, height: SIZE, alignment: .topTrailing)
                .position(x: x, y: y)
            
            Text("New")
                .foregroundColor(FOREGROUND_COLOR)
                .font(Font.caption)
                .position(x: x, y: y)
        }
    }
    
}
