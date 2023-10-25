//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

//HARDCODED SECTION

let db = Firestore.firestore()

let chatroom = db.collection("Chatrooms").document("ChatRoom1").collection("Widgets").document("Drawings")

var imageView = ImageWidget(
position: CGPoint(x: 200, y: 1000),
size: [250, 250],
borderColor: Color(.black),
image: Image("jennie kim"))

var imageView2 = ImageWidget(
position: CGPoint(x: 200, y: 1000),
size: [250, 250],
borderColor: Color(.black),
image: Image("jonathan-pic"))

var imageView3 = ImageWidget(
position: CGPoint(x: 200, y: 1000),
size: [250, 250],
borderColor: Color(.black),
image: Image("josh-pic"))

var imageView4 = ImageWidget(
position: CGPoint(x: 200, y: 1000),
size: [250, 250],
borderColor: Color(.black),
image: Image("enzo-pic"))
//HARDCODED SECTION


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
    @State private var drawingMode: Bool = false
    @State private var penColor: Color = .black
    @State private var handFill: String = ""
    @State private var grabMode: Bool = false
    @State private var canvasWidgets: [CanvasWidget]
    @GestureState private var magnifyBy: CGFloat = 1.0
    
    
    init() {
        
        self.canvasWidgets = [imageView, imageView2, imageView3, imageView4]
        
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
    
    
    
    func onChange() async {
        
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
                    self.lines.append(line)
                })
            })
        } catch {
            print("something fucked up")
        }
        
    }
    
    
    
    func GridView() -> AnyView {
        
        let columns = Array(repeating: GridItem(.fixed(250), spacing: 15, alignment: .leading), count: 3)
        
        return AnyView(LazyVGrid(columns: columns, alignment: .leading, spacing: 250, content: {
            
            ReorderableForEach(items: canvasWidgets) { widget in
                widget.widgetView()
            } moveAction: { from, to in
                canvasWidgets.move(fromOffsets: from, toOffset: to)
            }}
        ))
    }

    func Toolbar() -> AnyView {
        
        AnyView(
            HStack{
                Image(systemName: "pencil")
                    .font(.largeTitle)
                    .foregroundColor(penColor)
                    .gesture(TapGesture(count: 1).onEnded({
                        if (drawingMode) {
                            self.penColor = Color.black
                            self.drawingMode = false
                        } else {
                            self.penColor = Color.red
                            self.drawingMode = true
                        }
                    }))
                Image(systemName: "hand.raised\(handFill)")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .gesture(TapGesture(count: 1).onEnded({
                        
                        if handFill.isEmpty {
                            self.handFill = ".fill"
                            self.grabMode = true
                        } else {
                            self.handFill = ""
                            self.grabMode = false
                        }
                        
                    }))
            }
        )
        
    }

    
    
    func canvasView() -> AnyView {
        
       AnyView(
            ZStack {
                GridView()
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
            }.frame(minWidth: 1000, minHeight: 1000)
        )
        
    }
    
    
    var magnification: some Gesture {
            MagnifyGesture()
                .updating($magnifyBy) { value, gestureState, transaction in
                    gestureState = value.magnification
                    print(magnifyBy)
                }
        }

    
    var body: some View {
        
        VStack {
            ScrollView([.horizontal,.vertical],showsIndicators: true) {
                    if drawingMode {
                        canvasView()
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
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
                    } else if grabMode {
                        canvasView()
                    } else {
                        canvasView()
                    }
            }.scrollDisabled(grabMode)//ScrollView
                .gesture(magnification)
                .scaleEffect(CGSize(width: magnifyBy, height: magnifyBy))
            Toolbar()
        }.task {
                await onChange()
        }

        
    }
    
    
    
}



struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage()
    }
}

