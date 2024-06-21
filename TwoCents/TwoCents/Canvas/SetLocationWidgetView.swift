import SwiftUI
import MapKit

struct SetLocationWidgetView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .onAppear {
                        setRegion(location.coordinate)
                    }
            } else {
                Text("Locating your position...")
            }
            
            Button(action: {
                if let location = locationManager.location {
                    print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                } else {
                    print("Location not available")
                }
            }) {
                Text("Get Current Location")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

struct SetLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
