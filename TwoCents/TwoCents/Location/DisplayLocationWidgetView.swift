//
//import SwiftUI
//import MapKit
//
//struct DisplayLocationWidgetView: UIViewRepresentable {
//    var latitude: String
//    var longitude: String
//    var radius: CLLocationDistance = 500
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.isZoomEnabled = false
//        mapView.isScrollEnabled = false
//        mapView.isPitchEnabled = false
//        mapView.isRotateEnabled = false
//        mapView.showsUserLocation = false
//        
//        if let lat = Double(latitude), let lon = Double(longitude) {
//            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//            let region = MKCoordinateRegion(
//                center: coordinate,
//                latitudinalMeters: radius * 2,
//                longitudinalMeters: radius * 2
//            )
//            mapView.setRegion(region, animated: true)
//            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            mapView.addAnnotation(annotation)
//        }
//        
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // No updates required for this example
//    }
//}
//
//struct CoordinateAnnotation: Identifiable {
//    let id = UUID()
//    var coordinate: CLLocationCoordinate2D
//}
//
//
//
//
//struct DisplayLocationWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        DisplayLocationWidgetView(latitude: "37.7749", longitude: "-122.4194")
//    }
//}
//
//
//
//
import SwiftUI
import MapKit

// Conform MKPointAnnotation to Identifiable
extension MKPointAnnotation: Identifiable {}

struct DisplayLocationWidgetView: View {
    var latitude: String
    var longitude: String
    var radius: CLLocationDistance = 500
    
    @State private var region = MKCoordinateRegion()
    @State private var annotation = MKPointAnnotation()
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: [annotation]
        ) { annotation in
            MapPin(coordinate: annotation.coordinate, tint: .red)
        }
        .onAppear {
            if let lat = Double(latitude), let lon = Double(longitude) {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: radius,
                    longitudinalMeters: radius
                )
                annotation.coordinate = coordinate
            }
        }
        .disabled(true) // Disable user interactions
    }
}

struct DisplayLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayLocationWidgetView(latitude: "37.7749", longitude: "-122.4194")
    }
}
