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

    var body: some View {
        VStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: [selectedLocation].compactMap { $0 }
            ) { location in
                MapPin(coordinate: location.coordinate, tint: .red)
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

            HStack {
                Button(action: {
                    withAnimation{
                        if let location = locationManager.location {
                            let coordinate = location.coordinate
                            setRegion(coordinate)
                            selectedLocation = IdentifiableLocation(coordinate: coordinate)
                        }
                    }
                }) {
                    Text("Recenter to Current Location")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
        }
        .padding()
        .onAppear {
            // Ensure updates are done on the main thread
            DispatchQueue.main.async {
                withAnimation{
                    if let location = locationManager.location {
                        let coordinate = location.coordinate
                        setRegion(coordinate)
                        selectedLocation = IdentifiableLocation(coordinate: coordinate)
                    }
                }
            }
        }
    }

    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    private func searchForLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            DispatchQueue.main.async {
                guard let response = response else {
                    print("Error searching for location: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                searchResults = response.mapItems
                showingSearchResults = true
            }
        }
    }
}

struct SetLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SetLocationWidgetView()
    }
}
