//
//  Untitled.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/31/24.
//

import SwiftUI

struct SearchResultsView: View {
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool // cotrol the focus state of text field
    
    var body: some View {
        VStack(alignment: .leading) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by location...", text: $searchText)
                    .foregroundColor(.gray)
                    .focused($isTextFieldFocused)  // 聚焦输入框
                                    .onAppear {
                                        isTextFieldFocused = true  // 视图出现时自动聚焦
                                    }
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
        .padding(.top)
        .background(Color.white)
        .cornerRadius(15)
    }
}
