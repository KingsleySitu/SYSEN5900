//
//  Untitled.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/31/24.
//

import SwiftUI

struct SearchResultsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text("Search by location...")
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "mic.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .padding()

            // Saved locations
            Text("Saved")
                .font(.headline)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                LocationRow(iconName: "house.fill", title: "Home", address: "131 Blair St, Ithaca, NY")
                LocationRow(iconName: "briefcase.fill", title: "Work", address: "Warren Hall, Reservoir Avenue, Ithaca, NY")
                LocationRow(iconName: "cart.fill", title: "Grocery Store", address: "135 Fairgrounds Memorial Pkwy, Ithaca, NY")
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
        .padding(.top)
        .background(Color.white)
        .cornerRadius(15)
    }
}
