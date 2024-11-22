//
//  Untitled.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/31/24.
//

import SwiftUI
import MapKit

struct SearchResultsView: View {
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchResults: [MKMapItem] = [] // 动态搜索结果
    
    var onSelectLocation: (CLLocationCoordinate2D, String) -> Void // 回调传递坐标和地址

    var body: some View {
        VStack(alignment: .leading) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by location...", text: $searchText)
                    .foregroundColor(.gray)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true // 自动聚焦
                    }
                    .onChange(of: searchText) { newValue in
                        performSearch(query: newValue) // 触发搜索
                    }
                Spacer()
                Image(systemName: "mic.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .padding()

            // 动态内容显示：搜索结果或默认信息
            if searchText.isEmpty {
                // 显示默认信息
                VStack(alignment: .leading) {
                    // 已保存的位置
                    Text("Saved")
                        .font(.headline)
                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 8) {
                        LocationRow(iconName: "house.fill", title: "Home", address: "120 Valentine Pl, Ithaca, NY")
                        LocationRow(iconName: "briefcase.fill", title: "Work", address: "Warren Hall, Reservoir Avenue, Ithaca, NY")
                    }
                    .padding(.horizontal)

                    // 最近访问的位置
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
                // 显示动态搜索结果
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(searchResults, id: \.self) { item in
                            Button(action: {
                                let coordinate = item.placemark.coordinate
                                onSelectLocation(coordinate, item.name ?? "Unknown Address")
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

    // 使用 MKLocalSearch 实现搜索
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
