//import SwiftUI
//import MapKit
//
//// Conform MKPointAnnotation to Identifiable
//extension MKPointAnnotation: Identifiable {
//    public var id: UUID {
//        return UUID()
//    }
//}
//
//struct DisplayLocationWidgetView: View {
//    var latitude: String
//    var longitude: String
//    var radius: CLLocationDistance = 500
//    
//    @State private var region = MKCoordinateRegion()
//    @State private var annotations: [MKPointAnnotation] = []
//    
//    var body: some View {
//        Map(
//            coordinateRegion: $region,
//            showsUserLocation: false,
//            annotationItems: annotations
//        ) { annotation in
//            MapAnnotation(coordinate: annotation.coordinate) {
//                Circle()
//                    .strokeBorder(Color(UIColor.systemBackground), lineWidth: 3)
//                    .background(Circle().fill(Color.red))
//                    .frame(width: 20, height: 20)
//            }
//        }
//        .onAppear {
//            if let lat = Double(latitude), let lon = Double(longitude) {
//                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//                region = MKCoordinateRegion(
//                    center: coordinate,
//                    latitudinalMeters: radius,
//                    longitudinalMeters: radius
//                )
//                
//                // Create and set annotation
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotations = [annotation]
//            }
//        }
//        .disabled(true) // Disable user interactions
//    }
//}
//
//struct DisplayLocationWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        DisplayLocationWidgetView(latitude: "37.7749", longitude: "-122.4194")
//    }
//}



//refactored above code to make map static... improves performance.

import SwiftUI
import MapKit

// Conform MKPointAnnotation to Identifiable
extension MKPointAnnotation: Identifiable {
    public var id: UUID {
        return UUID()
    }
}

// UIViewRepresentable to create a static map snapshot
struct StaticMapView: UIViewRepresentable {
    var latitude: Double
    var longitude: Double
    var radius: CLLocationDistance
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        uiView.setRegion(region, animated: false)
        
        // Remove any existing annotations
        uiView.removeAnnotations(uiView.annotations)
        
        // Add the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }
}

struct DisplayLocationWidgetView: View {
    var latitude: String
    var longitude: String
    var radius: CLLocationDistance = 500
    
    var body: some View {
        if let lat = Double(latitude), let lon = Double(longitude) {
            StaticMapView(latitude: lat, longitude: lon, radius: radius)
                .disabled(true) // Disable user interactions
        } else {
            Text("Invalid coordinates")
        }
    }
}

struct DisplayLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayLocationWidgetView(latitude: "37.7749", longitude: "-122.4194")
    }
}

