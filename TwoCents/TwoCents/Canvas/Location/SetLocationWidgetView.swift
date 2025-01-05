import SwiftUI
import MapKit

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


struct SetLocationWidgetView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
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
    
    
    @Binding  var closeNewWidgetview: Bool
    @State  var spaceId: String
    
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
                    
                    if newValue.isEmpty {
                        showingSearchResults = false
                    } else {
                        searchForLocation()
                    }
                    
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
                        VStack(alignment: .leading) {
                            // Display the location name or a default text if name is nil
                            Text(item.placemark.name ?? "Unknown location")
                                .font(.headline)
                            
                            // Prepare the throughfares text
                            let throughfares = [
                                item.placemark.subThoroughfare,
                                item.placemark.thoroughfare
                            ].compactMap { $0 }.joined(separator: " ")
                            
                            // Prepare the additional address details text
                            let additionalDetails = [
                                item.placemark.locality,
                                item.placemark.administrativeArea,
                                item.placemark.postalCode
                            ].compactMap { $0 }.joined(separator: ", ")
                            
                            // Combine throughfares and additionalDetails into one line, if available
                            let combinedDetails = [throughfares, additionalDetails]
                                .filter { !$0.isEmpty }
                                .joined(separator: ", ")
                            
                            // Display the combined details or an empty Text view if no details are available
                            if !combinedDetails.isEmpty {
                                Text(combinedDetails)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }


                    }
                }
                .scrollDismissesKeyboard(.interactively)
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
                        
                        Task{
                            try? await createNewMapWidget(location: "\(location.coordinate.latitude), \(location.coordinate.longitude)")
                            
                            closeNewWidgetview = true
                        }
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
    
    func createNewMapWidget(location:String) async {
        
       
        let uid: String
        let user: DBUser
        do {
            uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            user = try await UserManager.shared.getUser(userId: uid)
        } catch {
            print("Error getting user in NewPollViewModel")
            return
        }

        let newCanvasWidget: CanvasWidget = CanvasWidget(
            x: 0,
            y: 0,
            borderColor: Color.fromString(name: user.userColor!),
            userId: uid,
            media: .map,
            widgetName: "Map Widget",
            location: location
            
        )
        
        canvasViewModel.newWidget = newCanvasWidget
        canvasViewModel.canvasMode = .placement
        
    }
    
    
}

struct SetLocationWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SetLocationWidgetView(userColor: .constant(.green), closeNewWidgetview: .constant(false), spaceId: "")
    }
}
