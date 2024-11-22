import CoreLocation

// Class responsible for managing user's location using CoreLocation framework
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager() // CoreLocation's location manager instance
    @Published var userLocation: CLLocation? // Published property to store the user's current location
    @Published var isLocationReady = false // Published flag to indicate if the location data is ready
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined // Published property to track the current authorization status
    
    // Initializer
    override init() {
        super.init()
        print("LocationManager initialized")
        
        // Setting up location manager
        self.locationManager.delegate = self // Assign the delegate to handle location updates
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set the desired location accuracy to the best available
        self.locationManager.distanceFilter = kCLDistanceFilterNone // No distance filter, report all location changes
        self.locationManager.requestWhenInUseAuthorization() // Request authorization for location access when the app is in use
        self.locationManager.startUpdatingLocation() // Begin receiving location updates
    }
}

// Extension to conform to CLLocationManagerDelegate protocol
extension LocationManager: CLLocationManagerDelegate {
    // Called when the location manager receives new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // Safely unwrap the latest location
        print("Location updated: \(location.coordinate)") // Log the updated location
        userLocation = location // Update the user's location
        if !isLocationReady { // If location data wasn't ready before
            isLocationReady = true // Mark as ready
        }
    }
    
    // Called when the location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)") // Log the error description
    }
    
    // Called when the user's authorization status for location services changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization status changed to: \(status.rawValue)") // Log the new authorization status
        authorizationStatus = status // Update the published authorization status

        // If the user grants appropriate permissions, start updating location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
