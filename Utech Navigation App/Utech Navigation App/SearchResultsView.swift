//
//  SearchResultsView.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/31/24.
//

import SwiftUI
import MapKit

struct SearchResultsView: View {
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchResults: [MKMapItem] = [] // Dynamic search results array
    
    // Callback to pass coordinate, name, city, and state back to the parent view
    var onSelectLocation: (CLLocationCoordinate2D, String, String, String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search by location...", text: $searchText)
                    .foregroundColor(.gray)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        // Auto-focus the search text field
                        isTextFieldFocused = true
                    }
                    .onChange(of: searchText) { newValue in
                        // Trigger new search whenever the user updates the query
                        performSearch(query: newValue)
                    }
                
                Spacer()
                
                Image(systemName: "mic.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .padding()

            // Display either default info (if search is empty) or search results
            if searchText.isEmpty {
                // Default info: Saved and Recent locations
                VStack(alignment: .leading) {
                    // Saved locations
                    Text("Saved")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        LocationRow(iconName: "house.fill", title: "Home", address: "120 Valentine Pl, Ithaca, NY")
                        LocationRow(iconName: "briefcase.fill", title: "Work", address: "Warren Hall, Reservoir Avenue, Ithaca, NY")
                    }
                    .padding(.horizontal)

                    // Recent locations
                    Text("Recent")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<10) { _ in
                                LocationRow(iconName: "clock.fill", title: "Random Location", address: "Random Location Address")
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                // Display dynamic search results
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(searchResults, id: \.self) { item in
                            Button(action: {
                                let coordinate = item.placemark.coordinate
                                let name = item.name ?? "Unknown Address"
                                let city = item.placemark.locality ?? ""
                                let state = item.placemark.administrativeArea ?? ""
                                
                                // Pass selected location info back
                                onSelectLocation(coordinate, name, city, state)
                            }) {
                                LocationRow(
                                    iconName: "mappin.and.ellipse",
                                    title: item.name ?? "Unknown",
                                    address: item.placemark.title ?? "Unknown Address"
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top)
        .background(Color.white)
        .cornerRadius(15)
    }

    // Perform search using MKLocalSearch
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                DispatchQueue.main.async {
                    searchResults = items
                }
            }
        }
    }
}
