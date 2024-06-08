//
//  TextWidgetAlpha.swift
//  TwoCents
//
//  Created by Joshua Shen on 5/22/24.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct TextView: View {
    //@StateObject private var nvm = NewWidgetViewModel()
    @State private var inputText: String = ""
    @Binding var showPopup: Bool
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            // Text field for input
            TextField("Enter text", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isTextFieldFocused)

            // Button to submit text
            Button(action: {
                if !inputText.isEmpty {
                    let newText = CanvasWidget(borderColor: Color.accentColor, userId: "fOBAypBOWBVkpHEft3V3Dq9JJgX2", media: .text, textString: inputText)
                    SpaceManager.shared.uploadWidget(spaceId: "865CE76B-9948-4310-A2C7-5BE32B302E4A", widget: newText)
                    inputText = ""
                }
                showPopup.toggle()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
                    isTextFieldFocused = true // Add this line to focus text field on appear
                }
    }
//    func uploadText(text: String) {
//        let newText = CanvasWidget(borderColor: Color.accentColor, userId: "fOBAypBOWBVkpHEft3V3Dq9JJgX2", media: .text, textString: text)
//        let newTextWidget = textWidget(widget: newText)
//        do{
//    //        db.collection("spaces")
//    //            .document("865CE76B-9948-4310-A2C7-5BE32B302E4A")
//    //            .collection("widgets")
//    //            .addDocument(data: newTextWidget)
//            nvm.saveWidget(index: 0)
//        }
//        catch {
//            print("unable to upload text widget")
//        }
//    }

}

//func uploadText(text: String) {
//    let newText = CanvasWidget(borderColor: Color.accentColor, userId: "fOBAypBOWBVkpHEft3V3Dq9JJgX2", media: .text, textString: text)
//    let newTextWidget = textWidget(widget: newText)
//    do{
////        db.collection("spaces")
////            .document("865CE76B-9948-4310-A2C7-5BE32B302E4A")
////            .collection("widgets")
////            .addDocument(data: newTextWidget)
//        nvm.saveWidget(index: index)
//    }
//    catch {
//        print("unable to upload text widget")
//    }
//}
