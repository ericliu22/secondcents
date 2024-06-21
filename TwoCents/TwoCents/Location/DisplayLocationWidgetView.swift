
import SwiftUI
import MapKit

struct DisplayLocationWidgetView: UIViewRepresentable {
    var latitude: String
    var longitude: String
    var radius: CLLocationDistance = 500

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        
        if let lat = Double(latitude), let lon = Double(longitude) {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: radius * 2,
                longitudinalMeters: radius * 2
            )
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // No updates required for this example
    }
}

struct CoordinateAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}




struct DisplayLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayLocationWidgetView(latitude: "37.7749", longitude: "-122.4194")
    }
}




