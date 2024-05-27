//
//  TextWidgetAlpha.swift
//  TwoCents
//
//  Created by Joshua Shen on 5/22/24.
//
import Foundation
import SwiftUI

struct TextView: View {
    @State private var inputText: String = ""
    @State private var displayedText: String? = nil
    @Binding var showPopup: Bool
    @Binding var showTextDisplay: Bool
    @Binding var textToDisplay: String

    var body: some View {
        VStack {
            // Text field for input
            TextField("Enter text", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Button to submit text
            Button(action: {
                if !inputText.isEmpty {
                    textToDisplay = inputText
                    displayedText = inputText
                    inputText = ""
                    showTextDisplay = true
                }
                showPopup.toggle()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Display the text if it's not nil
            if let text = displayedText {
                TextDisplayView(text: text)
            }
        }
        .padding()
    }
}

// View to display the submitted text
struct TextDisplayView: View {
    var text: String

    var body: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
            .foregroundColor(Color.accentColor)
            .background(.thickMaterial)
    }
}


