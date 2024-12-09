import Foundation
import MapKit

class RouteCalculator {
    func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportMode: String,
        completion: @escaping (Result<(distance: String, travelTime: String, polyline: MKPolyline), Error>) -> Void
    ) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        
        switch transportMode {
        case "car":
            request.transportType = .automobile
        case "figure.walk":
            request.transportType = .walking
        case "bicycle":
            request.transportType = .walking
        case "bus", "tram":
            request.transportType = .transit
        default:
            request.transportType = .automobile
        }
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let route = response?.routes.first {
                let distance = route.distance / 1000.0 // Convert to kilometers
                let formattedDistance = String(format: "%.1f km", distance)
                
                let travelTime = route.expectedTravelTime / 60.0 // Convert to minutes
                let formattedTime = String(format: "%.0f min", travelTime)
                
                completion(.success((distance: formattedDistance, travelTime: formattedTime, polyline: route.polyline)))
            }
        }
    }
}
