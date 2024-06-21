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
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: IdentifiableLocation?
    
    @Binding  var userColor: Color
    @State private var isFocused = false
    var body: some View {
        VStack {
            
            HStack {
                TextField("Search for a location", text: $searchText, onEditingChanged: { editing in
                    // Show cancel button when editing
                    withAnimation {
                        isFocused = editing // Track focus state
                    }
                })
                .onChange(of: searchText) { newValue in
                    searchForLocation()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .submitLabel(.search)
                
                if isFocused ||  searchText != ""{
                    Button(action: {
                        searchText = "" // Clear search text
                        // Other actions to reset state
                        
                      
                        searchResults.removeAll()
                        showingSearchResults = false
                   
                        
                        
                        withAnimation{
                            isFocused = false // Reset focus state
                            
                       
                      
                            if let location = locationManager.location {
                                let coordinate = location.coordinate
                                setRegion(coordinate)
                                selectedLocation = IdentifiableLocation(coordinate: coordinate)
                            }
                            
                            
                        }
                        
                        
                        
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Cancel")
                            .foregroundColor(userColor) // Adjust color as needed
                    }
                }
            }
            .padding(.horizontal)
            
            
            if showingSearchResults {
                List(searchResults, id: \.self) { item in
                    Button(action: {
                        if let coordinate = item.placemark.location?.coordinate {
                            let location = IdentifiableLocation(coordinate: coordinate)
                            setRegion(coordinate)
                            selectedLocation = location
                            
                            withAnimation {
                                showingSearchResults = false
                                
                            }
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                         
                        }
                    }) {
                        Text(item.placemark.name ?? "Unknown location")
                    }
                }
                .listStyle(PlainListStyle())
                .padding(EdgeInsets())
//                
//                Button(action: {
//                    
//                    searchText = "" // Clear search text
//                    // Other actions to reset state
//                    
//                  
//                    searchResults.removeAll()
//                    showingSearchResults = false
//               
//                    
//                    
//                    withAnimation{
//                        isFocused = false // Reset focus state
//                        
//                    }
//                    
//                    
//                    withAnimation{
//                        if let location = locationManager.location {
//                            let coordinate = location.coordinate
//                            setRegion(coordinate)
//                            selectedLocation = IdentifiableLocation(coordinate: coordinate)
//                        }
//                        
//                        
//                    }
//                    
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }) {
//                    Text("Recenter to Current Location")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
                
                
            } else {
                
                
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: [selectedLocation].compactMap { $0 }
                ) { location in
                    MapPin(coordinate: location.coordinate, tint: userColor)
                }
                .disabled(true)
                .cornerRadius(10)
                .frame(maxHeight:500)
                .padding(.horizontal)
                
                Button(action: {
                    if let location = selectedLocation {
                        print("Selected location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    } else {
                        print("No location selected")
                    }
                    
                    
                }) {
                    Text("Select")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                }
                
                
                .buttonStyle(.bordered)
                .tint(userColor)
                .frame(height: 55)
                .cornerRadius(10)
                .padding(.horizontal)
            }

      
          Spacer()

              
        }
        .tint(userColor)
   
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
                
                withAnimation {
                    showingSearchResults = true
                }
                
            }
        }
    }
    
   
    
}

struct SetLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SetLocationWidgetView(userColor: .constant(.green))
    }
}
