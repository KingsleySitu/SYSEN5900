//
//  ContentView.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // MARK: - Properties
    
    @State private var selectedTransportMode: String = "car" // Default selected transport mode is 'car'
    @State private var isDirectionsMode: Bool = false        // Controls whether the bottom sheet shows directions mode
    @State private var isShowingBottomSheet: Bool = false    // Controls the visibility of the bottom sheet
    @State private var currentMarkerDetails: String? = nil   // Additional details for the selected marker
    @State private var currentMarkerCity: String = ""        // City associated with the current marker
    @State private var currentMarkerState: String = ""       // State associated with the current marker
    
    // Current marker information: coordinate and title
    @State private var currentMarker: (coordinate: CLLocationCoordinate2D, title: String)? = nil
    
    // Location manager to handle user's location
    @StateObject private var locationManager = LocationManager()
    
    // Map camera position state
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Visible region on the map
    @State private var visibleRegion: MKCoordinateRegion?
    
    // Search view presentation state
    @State private var isSearching: Bool = false
    
    // Map style toggle state (e.g., to switch between normal and air quality map)
    @State private var isAirQualityMap: Bool = false
    
    // Loading screen state
    @State private var isShowingLoadingScreen = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main map content
            if locationManager.isLocationReady {
                // Primary map view
                mapView
                    .opacity(isShowingLoadingScreen ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: isShowingLoadingScreen)
                
                // Overlay controls (buttons, search bar, etc.)
                controlsOverlay
                    .opacity(isShowingLoadingScreen ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isShowingLoadingScreen)
            }
            
            // Bottom sheet
            VStack {
                Spacer()
                if isShowingBottomSheet {
                    bottomSheet
                        .onTapGesture {
                            // Tap to close bottom sheet
                            isShowingBottomSheet = false
                        }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // Loading overlay
            if isShowingLoadingScreen {
                LoadingView {
                    // Callback once loading animation is completed
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingLoadingScreen = false
                    }
                }
                .transition(.opacity)
            }
        }
        // Present search sheet when isSearching is true
        .sheet(isPresented: $isSearching) {
            SearchResultsView { coordinate, address, city, state in
                // Update camera position and marker information based on search result
                withAnimation(.easeInOut(duration: 1.0)) {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                        )
                    )
                    currentMarker = (coordinate, address)
                    currentMarkerCity = city
                    currentMarkerState = state
                    isShowingBottomSheet = true
                }
                isSearching = false
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // User's current location annotation
            if let userLocation = locationManager.userLocation {
                Annotation("", coordinate: userLocation.coordinate) {
                    locationAnnotation
                }
            }
            
            // Selected address annotation
            if let marker = currentMarker {
                Annotation(marker.title, coordinate: marker.coordinate) {
                    markerAnnotation()
                }
            }
        }
        .mapControls {
            MapCompass()
        }
        .mapStyle(isAirQualityMap ? .imagery : .standard)
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .onAppear {
            // Initialize camera position to the user's location if available
            if let location = locationManager.userLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                    )
                )
            }
        }
    }
    
    // Marker annotation symbol
    private func markerAnnotation() -> some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(.red)
    }
    
    // MARK: - Location Annotation for User Position
    
    private var locationAnnotation: some View {
        ZStack {
            // Outer translucent circle
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
            
            // Inner solid circle
            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
            
            // White stroke circle
            Circle()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 16, height: 16)
        }
    }
    
    // MARK: - Bottom Sheet
    
    private var bottomSheet: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingBottomSheet = false
                        isDirectionsMode = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing)
            .padding(.top)
            
            if isDirectionsMode {
                directionsContent
            } else {
                locationDetailsContent
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
        .padding(.horizontal)
        .padding(.bottom, 45)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.3), value: isShowingBottomSheet)
    }
    
    // Location details content (non-directions mode)
    private var locationDetailsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let marker = currentMarker {
                Text(marker.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Display static Air Quality info (placeholder)
                Text("Air Quality Index: Moderate (100)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Button to switch to directions mode
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDirectionsMode = true
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.turn.up.right")
                            .foregroundColor(.white)
                        Text("Directions")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .transition(.move(edge: .trailing))
    }
    
    // Directions content (when isDirectionsMode is true)
    private var directionsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let marker = currentMarker {
                Text(marker.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(currentMarkerCity), \(currentMarkerState)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Transport mode icons
            HStack(spacing: 20) {
                Spacer()
                ForEach(["car", "figure.walk", "bus", "tram", "bicycle"], id: \.self) { mode in
                    Button(action: {
                        selectedTransportMode = mode
                    }) {
                        Image(systemName: mode)
                            .foregroundColor(selectedTransportMode == mode ? .green : .gray)
                            .font(.title2)
                            .padding(8)
                            .background(
                                selectedTransportMode == mode
                                ? Color.green.opacity(0.2)
                                : Color.gray.opacity(0.1)
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            
            // Route details
            VStack(alignment: .leading, spacing: 5) {
                Text("35 min (3.5 mi)")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text("High traffic • No tolls")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Start navigation button
            Button(action: {
                print("Start navigation with mode: \(selectedTransportMode)")
            }) {
                HStack {
                    Image(systemName: "arrow.turn.up.right")
                        .foregroundColor(.white)
                    Text("Start")
                        .foregroundColor(.white)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        VStack {
            // Top controls (settings, recenter, map style toggle)
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    controlButton(
                        icon: "gearshape.fill",
                        action: { print("Settings tapped") }
                    )
                    controlButton(
                        icon: "location.fill",
                        action: centerMapOnUserLocation
                    )
                    controlButton(
                        icon: isAirQualityMap ? "aqi.high" : "map.fill",
                        action: { withAnimation { isAirQualityMap.toggle() } }
                    )
                }
                .padding(.top, 80)
                .padding(.trailing, 20)
            }
            
            Spacer()
            
            // Bottom search bar
            searchBar
        }
    }
    
    // MARK: - Control Button
    
    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            Text("Search location...")
                .foregroundColor(.gray)
                .onTapGesture {
                    isSearching = true
                }
            Spacer()
            Image(systemName: "mic.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, 50)
    }
    
    // MARK: - Helper Functions
    
    private func centerMapOnUserLocation() {
        if let location = locationManager.userLocation {
            withAnimation(.easeInOut(duration: 1.0)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                    )
                )
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
