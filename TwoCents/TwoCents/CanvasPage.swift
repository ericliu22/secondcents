//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore



let imageView = ImageWidget(
    position: CGPoint(x: 200, y: 1000),
    size: [200,300],
    borderColor: Color(.black),
    image: Image("jennie kim")).widgetView()
let videoView = VideoWidget(
    position: CGPoint(x: 600, y:1000),
    size: [400,400],
    borderColor: Color(.red),
    videoName: "lisa manoban",
    extensionName: "mp4"
    ).widgetView()


let db = Firestore.firestore()

let chatroom = db.collection("Chatrooms").document("ChatRoom1").collection("Widgets").document("Drawings")

func pushDrawing(userId: String, userColor: Color, lines: [Line]) {
    if userId.isEmpty {
        print("UID not loaded yet")
        return
    }
    
    var FirebaseLineArray: [Dictionary<String, Any>] = []
    for line in lines {
        FirebaseLineArray.append(line.toFirebase())
    }
    
    do {
        chatroom.updateData([userId: FieldValue.arrayUnion(FirebaseLineArray)])
    } catch {
        chatroom.setData([
            "color \(userId)": userColor.description
        ])
        chatroom.setData([userId: FirebaseLineArray])
    }
}


func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}

struct CanvasPage: View {
    
    @State private var userUID: String = ""
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var drawingMode = false
    @State private var penColor: Color = .black
    
    init() {
        
    }
    
    let pullDrawing = chatroom.addSnapshotListener {
        documentSnapshot, error in guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
        }
        guard let data = document.data() else {
            print("Empty document")
            return
        }
        
    }

    
    var body: some View {
        VStack {
            ScrollView([.horizontal,.vertical],showsIndicators: false) {
                    if drawingMode {
                        ZStack {
                            imageView
                            videoView
                            Canvas { context, size in
                                for line in lines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                                    print(line.points)
                                }
                            }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                                if (drawingMode) {
                                    let newPoint = value.location
                                    currentLine.points.append(newPoint)
                                    self.lines.append(currentLine)
                                    
                                }
                            })
                                .onEnded({value in
                                    if (drawingMode) {
                                        self.lines.append(currentLine)
                                        self.currentLine = Line()
                                        pushDrawing(userId: userUID, userColor: penColor, lines: self.lines)
                                    }
                                })
                            )
                            .frame(minWidth: 1600, minHeight: 1600)
                        }
                    } else {
                        ZStack {
                            imageView
                            videoView
                            Canvas { context, size in
                                for line in lines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                                    print(line.points)
                                }
                                
                            }
                            .frame(minWidth: 1600, minHeight: 1600)
                        }
                    }
            }.task {
                do {
                    try await self.userUID = getUID()!
                            var dbDrawings: Dictionary<String, Any>
                    do {
                        dbDrawings = try await chatroom.getDocument().data()!
                    } catch {
                        return
                    }
                    dbDrawings.forEach({ key, value in
                        let drawingArray: [Dictionary<String, Any>] = value as! [Dictionary<String, Any>]
                        drawingArray.forEach({ map in
                            var line = Line()
                            let usercolor: Color = Color.fromString(name: map["color"] as! String)
                            let penWidth: Double = Double(exactly: map["lineWidth"] as! NSNumber)!
                            
                            print(usercolor.description)
                            print("linewidth \(penWidth)")
                            line.color = usercolor
                            line.lineWidth = penWidth
                            
                            let floatsArray: NSArray = map["points"] as! NSArray
                            var pointsArray: [CGPoint] = []
                            
                            for i in stride(from: 0, to: floatsArray.count, by: 2) {
                                let y: CGFloat = CGFloat(truncating: floatsArray[i] as! NSNumber)
                                let x: CGFloat = CGFloat(truncating: floatsArray[i+1] as! NSNumber)
                                pointsArray.append(CGPoint(x: x, y: y))
                            }
                                                   
                            line.points = pointsArray
                            print(line)
                            self.lines.append(line)
                        })
                    })
                } catch {
                    print("something fucked up")
                }
            }//ScrollView
            Image(systemName: "pencil")
                .font(.largeTitle)
                .foregroundColor(penColor)
                .gesture(TapGesture(count: 1).onEnded({
                    if (drawingMode) {
                        penColor = Color.black
                        drawingMode = false
                    } else {
                        penColor = Color.red
                        drawingMode = true
                    }
                }))
        }
    }
}

struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage()
    }
}

