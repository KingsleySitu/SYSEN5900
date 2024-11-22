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
    
    // Location manager to handle user's location
    @StateObject private var locationManager = LocationManager()
    
    // Map camera position state
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Visible region on the map
    @State private var visibleRegion: MKCoordinateRegion?
    
    // Search view presentation state
    @State private var isSearching: Bool = false
    
    // Map type toggle state
    @State private var isAirQualityMap: Bool = false
    
    // Loading screen state
    @State private var isShowingLoadingScreen = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main map content
            if locationManager.isLocationReady {
                // Main map view
                mapView
                    .opacity(isShowingLoadingScreen ? 0 : 1) // Fade in map when loading completes
                    .animation(.easeInOut(duration: 0.5), value: isShowingLoadingScreen)
                
                // Overlay controls
                controlsOverlay
                    .opacity(isShowingLoadingScreen ? 0 : 1) // Fade in controls when loading completes
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isShowingLoadingScreen) // Slight delay for controls
            }
            
            // Loading screen overlay with transition
            if isShowingLoadingScreen {
                LoadingView {
                    // Callback when loading animation completes
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingLoadingScreen = false
                    }
                }
                .transition(.opacity)
            }
        }
        // Present search sheet when isSearching is true
        .sheet(isPresented: $isSearching) {
            SearchResultsView()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // Add user's location annotation if available
            if let userLocation = locationManager.userLocation {
                Annotation("", coordinate: userLocation.coordinate) {
                    locationAnnotation
                }
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
        }
        // Set map style based on isAirQualityMap flag
        .mapStyle(isAirQualityMap ? .imagery : .standard)
        // Track map camera changes
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        // Set initial camera position
        .onAppear {
            if let location = locationManager.userLocation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                ))
            }
        }
    }
    
    // MARK: - Location Annotation
    
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
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        VStack {
            // Top controls
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    // Settings button
                    controlButton(
                        icon: "gearshape.fill",
                        action: { print("Settings tapped") }
                    )
                    
                    // Location button
                    controlButton(
                        icon: "location.fill",
                        action: centerMapOnUserLocation
                    )
                    
                    // Map type toggle button
                    controlButton(
                        icon: isAirQualityMap ? "aqi.high" : "map.fill",
                        action: { withAnimation { isAirQualityMap.toggle() } }
                    )
                }
                .padding(.top, 80)
                .padding(.trailing, 20)
            }
            
            Spacer()
            
            // Search bar
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
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                ))
            }
        }
    }
}

#Preview {
    ContentView()
}
