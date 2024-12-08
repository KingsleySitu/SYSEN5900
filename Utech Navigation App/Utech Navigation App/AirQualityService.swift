//
//  AirQualityService.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 12/7/24.
//
import Foundation
import CoreLocation

struct AQIResponse: Decodable {
    let dateTime: String
    let regionCode: String
    let indexes: [AQIIndex]
}

struct AQIIndex: Decodable {
    let code: String
    let displayName: String
    let aqi: Int
    let aqiDisplay: String
    let color: AQIColor
    let category: String
    let dominantPollutant: String
}

struct AQIColor: Decodable {
    let red: Double
    let green: Double
    let blue: Double
}

class AirQualityService {
    func fetchAirQuality(for coordinate: CLLocationCoordinate2D, completion: @escaping (Result<AQIResponse, Error>) -> Void) {
        let apiUrl = "https://airquality.googleapis.com/v1/currentConditions:lookup?key=AIzaSyD6C4YBNNKtvw7gwX1k-03RUMb2NivAU_A"
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body
        let body: [String: Any] = [
            "location": [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        ]

        // Convert body to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // Make the POST request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -2)))
                return
            }

            do {
                // Decode the JSON response into AQIResponse
                let aqiResponse = try JSONDecoder().decode(AQIResponse.self, from: data)
                completion(.success(aqiResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
