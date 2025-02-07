import SwiftUI

struct OffScreenIndicator: View {

    // For identifying which widget we’re pointing to
    let widgetId: String

    // If you have the widget itself (with x, y, width, height), you might pass
    // the whole `CanvasWidget` to avoid a second lookup in the canvasViewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    // State for angle, color, user info, etc.
    @State var userColor: Color = .gray
    @State var angle: CGFloat = 0   // degrees or radians, whichever you prefer
    @State var user: DBUser?
    
    var body: some View {
        if
            let widget = canvasViewModel.canvasWidgets.first(where: {
                $0.id.uuidString == widgetId
            }) {
            GeometryReader { proxy in
                // 1) The screen’s center in local coordinates
                let screenSize = proxy.size
                let screenCenter = CGPoint(x: screenSize.width / 2,
                                           y: screenSize.height / 2)
                
                // 2) Find the widget we’re pointing to
                
                let widgetRect = CGRect(
                    x: widget.x ?? 0,
                    y: widget.y ?? 0,
                    width: widget.width,
                    height: widget.height
                )
                if !widgetRect.intersects(canvasViewModel.visibleRectInCanvas) {
                    // 3) Calculate the angle between the scrollCenter and the widget's center
                    //    If your (0,0) is truly top-left in the canvas,
                    //    then `widget.x, widget.y` is also top-left.
                    //    Often you want the widget's center:
                    let widgetCenterX = (widget.x ?? 0) + widget.width / 2
                    let widgetCenterY = (widget.y ?? 0) + widget.height / 2
                    
                    // The difference in unscaled coords
                    let dx = widgetCenterX - canvasViewModel.canvasPageCursor.x
                    let dy = widgetCenterY - canvasViewModel.canvasPageCursor.y
                    
                    // Angle in radians
                    let radians = atan2(dy, dx)
                    let degrees = radians * 180 / .pi
                    
                    // 4) Project to the edge of the screen so that the indicator sits
                    //    on a circle at the screen’s perimeter (minus some padding)
                    let radius = min(screenSize.width, screenSize.height) / 2 - 40
                    let x = screenCenter.x + cos(radians) * radius
                    let y = screenCenter.y + sin(radians) * radius
                    let center = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
                    
                    
                    let edgePoint = pointOnScreenEdge(
                        screenSize: proxy.size,
                        center: screenCenter,
                        angle: radians
                    )
                    // 5) Your indicator
                    ZStack {
                        // The pin or tear-drop shape
                        Pin(userColor: $userColor)
                        // If your teardrop tip is "down", you might add +90° or +180° offset
                        // so that it visually points at the widget
                            .rotationEffect(.radians(radians - .pi/2))
                        // or if you prefer degrees: .rotationEffect(.degrees(degrees + 180))
                        
                        // Possibly an avatar or text overlay
                        if let user {
                            if let profileImageUrl = user.profileImageUrl {
                                CachedUrlImage(imageUrl: URL(string: profileImageUrl)!)
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)

                            } else {
                                Text("New")
                            }
                        }
                    }
                    .position(x: edgePoint.x, y: edgePoint.y)
                    // Tapping it scrolls to the widget
                    .onTapGesture {
                        // Possibly call your scrollToWidget here
                        // e.g. canvasViewModel.scrollToWidget(widget)
                        // or environment(\.scrollToWidget) if you followed that approach
                        canvasViewModel.coordinator?.scrollToWidget(widget)
                    }
                    .task {
                        // Load user info, etc.
                        do {
                            self.user = self.canvasViewModel.members[id: widget.userId]
                            guard let user = self.user else {
                                return
                            }
                            self.userColor = Color.fromString(name: user.userColor ?? "gray")
                        } catch {
                            print("Error fetching user: \(error)")
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        } else {
            EmptyView()
                .onAppear {
                    print(widgetId)
                }
        }
    }
}


struct Pin: View {
    
    @Binding var userColor: Color
    
    init(userColor: Binding<Color>) {
        self._userColor = userColor
    }
    
    var body: some View {
        ZStack {
            TearDropShape()
                .fill(userColor)
                .overlay(
                    TearDropShape()
                        .stroke(userColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                )
                .frame(width: 90, height: 100)
                .rotationEffect(.degrees(180))
        }
    }
}

struct TearDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var pencil = Path()
        
        let startingPoint = CGPoint(x: rect.midX, y: rect.minY)
        
        let relativeWidth = rect.maxX - rect.minX
        let relativeHeight = rect.maxY - rect.minY
        
        pencil.move(to: startingPoint)
        
        let point1 = CGPoint(x: rect.minX + relativeWidth / 4, y: rect.midY)
        pencil.addLine(to: point1)
        
        pencil.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: relativeWidth / 4, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)

        pencil.addLine(to: startingPoint)
        return pencil
    }
}

func pointOnScreenEdge(
  screenSize: CGSize,
  center: CGPoint,
  angle: CGFloat,
  margin: CGFloat = 50  // enough so our shape is fully on-screen
) -> CGPoint {
    let width = screenSize.width
    let height = screenSize.height

    // We define “inset edges”
    let leftEdge = margin
    let rightEdge = width - margin
    let topEdge = margin
    let bottomEdge = height - margin

    let dx = cos(angle)
    let dy = sin(angle)

    var tCandidates: [CGFloat] = []

    // For the left edge: x=leftEdge => leftEdge = cx + t*dx => t = (leftEdge - cx)/dx
    if dx != 0 {
        let tLeft = (leftEdge - center.x)/dx
        if dx < 0, tLeft > 0 { tCandidates.append(tLeft) }
        
        let tRight = (rightEdge - center.x)/dx
        if dx > 0, tRight > 0 { tCandidates.append(tRight) }
    }

    // For the top edge: y=topEdge => topEdge = cy + t*dy => t = (topEdge - cy)/dy
    if dy != 0 {
        let tTop = (topEdge - center.y)/dy
        if dy < 0, tTop > 0 { tCandidates.append(tTop) }
        
        let tBottom = (bottomEdge - center.y)/dy
        if dy > 0, tBottom > 0 { tCandidates.append(tBottom) }
    }

    guard let tMin = tCandidates.min() else {
        // If no valid intersection, just return center
        return center
    }

    let edgeX = center.x + dx * tMin
    let edgeY = center.y + dy * tMin
    return CGPoint(x: edgeX, y: edgeY)
}
