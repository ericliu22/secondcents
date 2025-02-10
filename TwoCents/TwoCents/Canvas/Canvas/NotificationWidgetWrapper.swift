//
//  NotificationWidgetWrapper.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct NotificationWidgetWrapper : View {
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State var loadedColor: Color = .gray
    let widgetUserId: String
    private let FOREGROUND_COLOR: Color = .white
    private let SIZE = 20.0
    
    init(widgetUserId: String) {
        self.widgetUserId = widgetUserId
    }
    
    func loadColor(widgetUserId: String) {
        guard let colorName = canvasViewModel.members[id: widgetUserId]?.userColor else {
            return
        }
        loadedColor = Color.fromString(name: colorName)
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(loadedColor)
                .frame(width: SIZE, height: SIZE, alignment: .topTrailing)
            
            Text("New")
                .foregroundColor(FOREGROUND_COLOR)
                .font(Font.caption)
        }
        .onAppear {
            loadColor(widgetUserId: widgetUserId)
        }
    }
    
}
