import SwiftUI
import MapKit

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


struct SetLocationWidgetView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: IdentifiableLocation?
    @State private var locationSet = false
    
    var body: some View {
        VStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: [selectedLocation].compactMap { $0 }
            ) { location in
                MapPin(coordinate: location.coordinate, tint: .red)
            }
            .onChange(of: locationManager.location) { newLocation in
                if let newLocation = newLocation, !locationSet {
                    let coordinate = newLocation.coordinate
                    setRegion(coordinate)
                    selectedLocation = IdentifiableLocation(coordinate: coordinate)
                    locationSet = true
                }
            }

            HStack {
                TextField("Search for a location", text: $searchText, onCommit: {
                    searchForLocation()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Button(action: {
                    searchForLocation()
                }) {
                    Image(systemName: "magnifyingglass")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            if showingSearchResults {
                List(searchResults, id: \.self) { item in
                    Button(action: {
                        if let coordinate = item.placemark.location?.coordinate {
                            let location = IdentifiableLocation(coordinate: coordinate)
                            setRegion(coordinate)
                            selectedLocation = location
                            showingSearchResults = false
                        }
                    }) {
                        Text(item.placemark.name ?? "Unknown location")
                    }
                }
            }

            Button(action: {
                if let location = selectedLocation {
                    print("Selected location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                } else {
                    print("No location selected")
                }
            }) {
                Text("Get Selected Location Coordinates")
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

    private func searchForLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("Error searching for location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            searchResults = response.mapItems
            showingSearchResults = true
        }
    }
}

struct SetLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SetLocationWidgetView()
    }
}
