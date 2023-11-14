//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import PencilKit


//CONSTANTS
let db = Firestore.firestore()

let TILE_SIZE: CGFloat = 100
let MAX_ZOOM: CGFloat = 3.0
let MIN_ZOOM: CGFloat = 1.0
let CORNER_RADIUS: CGFloat = 15
let LINE_WIDTH: CGFloat = 5

//HARDCODED SECTION

let chatroom = db.collection("Chatrooms").document("ChatRoom1").collection("Widgets").document("Drawings")

var imageView0 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!)
var imageView1 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://www.billboard.com/wp-content/uploads/2023/01/lisa-blackpink-dec-2022-billboard-1548.jpg?w=942&h=623&crop=1")!)
var imageView2 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://i.mydramalist.com/66L5p_5c.jpg")!)
var imageView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://static.wikia.nocookie.net/the_kpop_house/images/6/60/Jisoo.jpg/revision/latest?cb=20200330154248")!)

var videoView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://video.link/w/vl6552d3ab6cdff#")!)
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
    @State private var frameSize: CGFloat = 1000
    @State private var canvasWidgets: [CanvasWidget] = []
    @State private var draggingItem: CanvasWidget?
    @State private var magnifyBy: CGFloat = 1.0
    
    
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
    
    
    
    func onChange() async {
        self.canvasWidgets = [imageView0, imageView1, imageView2, imageView3, videoView3]
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
        
        let columns = Array(repeating: GridItem(.fixed(TILE_SIZE), spacing: 15, alignment: .leading), count: 3)

        return AnyView(LazyVGrid(columns: columns, alignment: .leading, spacing: 15, content: {
            
            ForEach(canvasWidgets, id:\.id) { widget in
               
                ZStack {
                    getMediaView(widget: widget)
                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                        .stroke(widget.borderColor, lineWidth: LINE_WIDTH)
                        .frame(width: widget.width, height: widget.height)
                }.draggable(widget) {
                    getMediaView(widget: widget).onAppear{
                        draggingItem = widget
                    }
                }.dropDestination(for: CanvasWidget.self) { items, location in
                    draggingItem = nil
                    return false
                } isTargeted: { status in
                    if let draggingItem, status, draggingItem != widget {
                        if let sourceIndex = canvasWidgets.firstIndex(of: draggingItem),
                            let destinationIndex = canvasWidgets.firstIndex(of: widget) {
                                withAnimation(.bouncy) {
                                    let sourceItem = canvasWidgets.remove(at: sourceIndex)
                                    canvasWidgets.insert(sourceItem, at: destinationIndex)
                                }
                            }
                    }
                }
            }
            }
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
        
        if grabMode {
           return AnyView(
                ZStack {
                    GridView()
                }.frame(minWidth: frameSize, minHeight: frameSize)
            )
        }
       return AnyView(
            ZStack {
                GridView()
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
            }.frame(minWidth: frameSize, minHeight: frameSize)
        )
        
    }
    
    
    var magnification: some Gesture {
        MagnificationGesture().onChanged { value in
            if value < MAX_ZOOM && value > MIN_ZOOM { magnifyBy = value }
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
                .scaleEffect(magnifyBy)
                .gesture(magnification)
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

