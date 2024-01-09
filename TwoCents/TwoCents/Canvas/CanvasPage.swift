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
let FRAME_SIZE: CGFloat = 1000

//HARDCODED SECTION


var imageView0 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!)
var imageView1 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://www.billboard.com/wp-content/uploads/2023/01/lisa-blackpink-dec-2022-billboard-1548.jpg?w=942&h=623&crop=1")!)
var imageView2 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://i.mydramalist.com/66L5p_5c.jpg")!)
var imageView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://static.wikia.nocookie.net/the_kpop_house/images/6/60/Jisoo.jpg/revision/latest?cb=20200330154248")!)

var videoView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://video.link/w/vl6552d3ab6cdff#")!)

var chatview = CanvasWidget(borderColor: .blue, userId: "shenjjj", media: .chat, mediaURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)
//HARDCODED SECTION




func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}

struct CanvasPage: View {
    
    
    
    @State private var userUID: String = ""
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var penColor: Color = .red
    @State private var currentMode: canvasState = .normal
    @State private var drawingMode: drawingState = .pencil
    @State private var canvasWidgets: [CanvasWidget] = []
    @State private var draggingItem: CanvasWidget?
    @State private var scrollPosition: CGPoint = CGPointZero
    @State private var magnifyBy: CGFloat = 1.0
    @State private var activeGestures: GestureMask = .none
    @State private var newWidget: Bool = false
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference
    
    enum canvasState {
        
        case drawing, grab, normal
        
    }
    enum drawingState {
        
        case pencil, eraser
        
    }
    
    init(chatroom: DocumentReference) {
        self.chatroomDocument = chatroom
        self.drawingDocument = chatroom.collection("Widgets").document("Drawings")
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

    }
    
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
            drawingDocument.updateData([userId: FieldValue.arrayUnion(FirebaseLineArray)])
        } catch {
            drawingDocument.setData([
                "color \(userId)": userColor.description
            ])
            drawingDocument.setData([userId: FirebaseLineArray])
        }
        
    }

    
    
    
    
    func onChange() async {
        self.canvasWidgets = [imageView0, imageView1, imageView2, imageView3, videoView3, chatview]
        do {
            try await self.userUID = getUID()!
            var dbDrawings: Dictionary<String, Any>
//            do {
//                dbDrawings = try await drawingDocument.getDocument().data()!
//            } catch {
//                return
//            }
            
            
            //Jonny changed from above do catch to "if let." so that app does not crash if drawing widget document/collections does not exist
            if let  dbDrawings = try await drawingDocument.getDocument().data() {
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
                
            }
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
                if (currentMode == .drawing) {
                    
                    Image(systemName: "arrowshape.backward.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .gesture(TapGesture(count: 1).onEnded({
                            withAnimation(.easeIn) {
                                    self.currentMode = .normal
                                    self.activeGestures = .none
                                }
                        }))
                    Image(systemName: "pencil.circle\(drawingMode == .pencil ? ".fill" : "")")
                        .font(.largeTitle)
                        .foregroundColor(drawingMode == .pencil ? penColor : .black)
                        .gesture(TapGesture(count: 1).onEnded({
                                self.drawingMode = .pencil
                        }))
                    Image(systemName: "eraser\(drawingMode == .eraser ? ".fill" : "")")
                        .font(.largeTitle)
                        .foregroundColor(drawingMode == .eraser ? penColor : .black)
                        .gesture(TapGesture(count: 1).onEnded({
                            self.drawingMode = .eraser
                        }))
                }
                else {
                    Image(systemName: "pencil.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .gesture(TapGesture(count: 1).onEnded({
                                withAnimation(.bouncy) {
                                    self.currentMode = .drawing
                                    self.activeGestures = .all
                                }
                        }))
                    Image(systemName: "hand.raised\(currentMode == .grab ? ".fill" : "")")
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                        .gesture(TapGesture(count: 1).onEnded({
                            if currentMode == .grab {
                                currentMode = .normal
                            } else {
                                self.currentMode = .grab
                                self.activeGestures = .subviews
                            }
                        }))
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .gesture(TapGesture(count:1).onEnded(({
                            
                            newWidget = true
                        })))
                }
            }
            
        )
        
    }

    
    
    func canvasView() -> AnyView {
        
       return AnyView(
            ZStack {
                GridView()
                    .zIndex(currentMode == .grab ? 1 : 0)
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
                .gesture(dragMode)
                .gesture(draw, including: activeGestures)
            }.frame(minWidth: FRAME_SIZE * magnifyBy, minHeight: FRAME_SIZE * magnifyBy)
        )
        
    }
    
    
    var magnification: some Gesture {
        MagnificationGesture().onChanged { value in
            print(value)
            if value > MAX_ZOOM {
                magnifyBy = MAX_ZOOM
            } else if value < MIN_ZOOM {
                magnifyBy = MIN_ZOOM
            } else {
                magnifyBy = value
            }
        }
    }
    
    var draw: some Gesture {
        
        DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged ({ value in
                let newPoint = value.location
                currentLine.points.append(newPoint)
                self.lines.append(currentLine)
            }).onEnded({value in
                self.lines.append(currentLine)
                self.currentLine = Line()
                pushDrawing(userId: userUID, userColor: penColor, lines: self.lines)
            })
        
    }
    
    var dragMode: some Gesture {
        
        LongPressGesture(minimumDuration: 1.0, maximumDistance: 1)
        .onEnded { value in
            print("grabmode")
            currentMode = .grab
        }
        
    }
    
    
    var body: some View {
        
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView([.horizontal,.vertical], showsIndicators: false) {
                        canvasView()
                    }.scrollDisabled(currentMode == .grab)
                        .scaleEffect(magnifyBy)
                        .gesture(magnification)
                }.task {
                    await onChange()
                }
            }
            Toolbar()
        }
            .overlay(alignment: .center) {
                if newWidget {
                    NewWidget()
                        .overlay(alignment: .topLeading) {
                            Image(systemName: "x.circle")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .gesture(TapGesture(count:1).onEnded(({
                                    newWidget = false
                                })))
                        }
                }
            }
            .toolbar(.hidden, for: .tabBar)
//            .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    
    
}



struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(chatroom: db.collection("Chatrooms").document("Chatroom1"))
    }
}
