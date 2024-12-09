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
    let routeCalculator = RouteCalculator()
    @State private var routeDetails: (distance: String, travelTime: String)? = nil
    @State private var selectedTransportMode: String = "car" // Default selected transport mode
    @State private var isDirectionsMode: Bool = false        // Controls directions mode in bottom sheet
    @State private var isShowingBottomSheet: Bool = false    // Controls bottom sheet visibility
    @State private var currentMarkerDetails: String? = nil   // Marker AQI details from API
    @State private var currentMarkerCity: String = ""        // City of current marker
    @State private var currentMarkerState: String = ""       // State of current marker
    @State private var routePolyline: MKPolyline? = nil // Store the calculated route
    
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
    
    // Map view mode state (standard, satellite, air quality)
    @State private var mapViewMode: MapViewMode = .standard
    
    // Loading screen state
    @State private var isShowingLoadingScreen = true
    
    // Air quality service instance
    let airQualityService = AirQualityService()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ZStack {
                // Main map content
                if locationManager.isLocationReady {
                    mapView
                        .opacity(isShowingLoadingScreen ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: isShowingLoadingScreen)
                }

                // Green overlay for air quality mode
                if mapViewMode == .airQuality {
                    Rectangle()
                        .fill(Color.green.opacity(0.3)) // Semi-transparent green overlay
                        .allowsHitTesting(false)       // Allow touch events to pass through
                        .edgesIgnoringSafeArea(.all)   // Cover the entire screen
                }

                // Overlay controls (e.g., right-side buttons)
                controlsOverlay
                    .opacity(isShowingLoadingScreen ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isShowingLoadingScreen)

                // AQI Reference Bar
                if mapViewMode == .airQuality {
                    HStack {
                        VStack {
                            Spacer()
                                .frame(height: 10) // Adjust height to align with the right-side buttons
                            AQIReferenceBar()
                                .frame(height: 300) // Set a reasonable height for the bar
                                .padding(.leading, 25) // Distance from the left edge
                            Spacer()
                        }
                        Spacer() // Push other elements to the right
                    }
                }

                // Bottom sheet
                VStack {
                    Spacer()
                    if isShowingBottomSheet {
                        bottomSheet
                            .onTapGesture {
                                isShowingBottomSheet = false
                            }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)

                // Loading overlay
                if isShowingLoadingScreen {
                    LoadingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isShowingLoadingScreen = false
                        }
                    }
                    .transition(.opacity)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Loading overlay
            if isShowingLoadingScreen {
                LoadingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingLoadingScreen = false
                    }
                }
                .transition(.opacity)
            }
        }
        // Show search sheet when isSearching is true
        .sheet(isPresented: $isSearching) {
            SearchResultsView { coordinate, address, city, state in
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
                
                // Fetch AQI from API
                airQualityService.fetchAirQuality(for: coordinate) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let aqiResponse):
                            if let firstIndex = aqiResponse.indexes.first {
                                // Update details with category and aqi
                                currentMarkerDetails = "\(firstIndex.category) (\(firstIndex.aqi))"
                            } else {
                                currentMarkerDetails = "No AQI data available"
                            }
                        case .failure:
                            currentMarkerDetails = "Failed to fetch AQI"
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // User location annotation
                if let userLocation = locationManager.userLocation {
                    Annotation("", coordinate: userLocation.coordinate) {
                        locationAnnotation
                    }
                }
                
                // Current marker annotation
                if let marker = currentMarker {
                    Annotation(marker.title, coordinate: marker.coordinate) {
                        markerAnnotation()
                    }
                }
            }
            .mapControls {
                MapCompass()
            }
            .mapStyle(
                mapViewMode == .satellite ? .imagery :
                mapViewMode == .airQuality ? .standard : .standard
            )
            .onAppear {
                if let location = locationManager.userLocation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                        )
                    )
                }
            }

            // Add MapOverlay for route polyline
            if let polyline = routePolyline {
                MapOverlay(polyline: polyline)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    // Marker annotation symbol
    private func markerAnnotation() -> some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(.red)
    }
    
    // User location annotation
    private var locationAnnotation: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
            
            Circle()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 16, height: 16)
        }
    }
    
    // MARK: - Bottom Sheet
    
    private var bottomSheet: some View {
        VStack(spacing: 15) {
            // Top section with title and close button
            HStack {
                Text(currentMarker?.title ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align title to the left
                
                Button(action: {
                    // Close the bottom sheet and reset direction mode
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingBottomSheet = false
                        isDirectionsMode = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8) // Add padding between the title and close button
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Conditional content based on direction mode
            if isDirectionsMode {
                directionsContent
            } else {
                locationDetailsContent
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5) // Add shadow for a floating effect
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.35) // Adjust the max height of the bottom sheet
        .padding(.horizontal) // Add horizontal padding for the sheet
        .padding(.bottom, 40) // Reduce bottom padding to make it more compact
        .transition(.move(edge: .bottom)) // Transition animation when the sheet appears
        .animation(.easeInOut(duration: 0.3), value: isShowingBottomSheet)
    }
    
    // Location details content
    private var locationDetailsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Display dynamic AQI info from currentMarkerDetails
            if let details = currentMarkerDetails {
                Text("Air Quality: \(details)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -30)
            } else {
                Text("Fetching Air Quality...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDirectionsMode = true
                    calculateRoute() // Trigger route calculation immediately when entering directions mode
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
        .padding()
        .transition(.move(edge: .trailing))
    }
    
    // Directions content
    private var directionsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if currentMarker != nil {
                Text("\(currentMarkerCity), \(currentMarkerState)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -30)
            }
            
            Divider()
            
            // Transport modes
            HStack(spacing: 20) {
                Spacer()
                ForEach(["car", "figure.walk", "bus", "tram", "bicycle"], id: \.self) { mode in
                    Button(action: {
                        selectedTransportMode = mode
                        calculateRoute()
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
            
            // Route details placeholder
            VStack(alignment: .leading, spacing: 5) {
                if let details = routeDetails {
                    Text("\(details.travelTime) (\(details.distance))")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Estimated travel time and distance")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Calculating route...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Start navigation button (placeholder action)
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
        .onAppear {
            // Automatically calculate route on appear
            calculateRoute()
        }
    }
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        VStack {
            // Top controls
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
                        icon: mapViewMode == .standard ? "map.fill" :
                              mapViewMode == .satellite ? "globe.americas.fill" : "aqi.high",
                        action: {
                            withAnimation {
                                toggleMapViewMode()
                            }
                        }
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
    
    // MARK: - Map View Mode Toggle
    
    private func toggleMapViewMode() {
        switch mapViewMode {
        case .standard:
            mapViewMode = .satellite
        case .satellite:
            mapViewMode = .airQuality
        case .airQuality:
            mapViewMode = .standard
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
                // Reset camera position to user's location
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                    )
                )
                // Clear navigation-related data
                routePolyline = nil // Clear the polyline
                routeDetails = nil  // Reset route details
                isDirectionsMode = false // Exit navigation mode
            }
        }
    }
    
    private func calculateRoute() {
        guard let source = locationManager.userLocation?.coordinate,
              let destination = currentMarker?.coordinate else {
            print("Source or destination is not available")
            return
        }
        
        routeCalculator.calculateRoute(from: source, to: destination, transportMode: selectedTransportMode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let details):
                    routeDetails = (details.distance, details.travelTime)
                    routePolyline = details.polyline // Store the route's polyline
                case .failure(let error):
                    routeDetails = nil
                    routePolyline = nil
                    print("Error calculating route: \(error)")
                }
            }
        }
    }
}


// Map view modes
enum MapViewMode {
    case standard
    case satellite
    case airQuality
}
