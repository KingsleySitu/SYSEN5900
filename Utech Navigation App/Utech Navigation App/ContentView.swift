//
//  ContentView.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var isSearching: Bool = false
    @State private var isAirQualityMap: Bool = false // New state to track map type
    
    private let initialRegion: MKCoordinateRegion = {
        let center = CLLocationCoordinate2D(latitude: 42.441624, longitude: -76.484693)
        let span = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        return MKCoordinateRegion(center: center, span: span)
    }()
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: 42.441624, longitude: -76.484693)) {
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
                
                Marker(
                    "Home",
                    coordinate: CLLocationCoordinate2D(latitude: 42.435782, longitude: -76.486605)
                )
            }
            .mapStyle(isAirQualityMap ? .imagery : .standard) // Toggle between map styles
            .onMapCameraChange(frequency: .onEnd) { context in
                visibleRegion = context.region
            }
            .onAppear {
                cameraPosition = .region(initialRegion)
            }
            
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Button(action: {
                            print("Settings tapped")
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.green)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                cameraPosition = .region(initialRegion)
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        // Modified map button to toggle between map types
                        Button(action: {
                            withAnimation {
                                isAirQualityMap.toggle()
                            }
                        }) {
                            Image(systemName: isAirQualityMap ? "aqi.high" : "map.fill")
                                .foregroundColor(.green)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 80)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text("Search by location...")
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
        }
        .sheet(isPresented: $isSearching) {
            SearchResultsView()
        }
        .edgesIgnoringSafeArea(.all)
    }
}


//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    // save search keyword
//    @State private var isSearching: Bool = false
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Image("backgroundImage")
//                    .resizable()
//                    .scaledToFill()
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    Spacer()
//                    // searchbar
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                        Text("Search by location...")
//                            .foregroundColor(.gray)
//                            .onTapGesture {
//                                isSearching = true
//                            }
//                        Spacer()
//                        Image(systemName: "mic.fill")
//                            .foregroundColor(.green)
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(25)
//                    .padding(.horizontal)
//                    .padding(.bottom, 50)
//                }
//            }
//            .sheet(isPresented: $isSearching) {
//                // refer to SearchResultsView
//                SearchResultsView()
//            }
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    VStack(spacing: 20) {
//                        Spacer().frame(height: 150)
//                        Button(action: {
//                            print("Settings tapped")
//                        }) {
//                            Image(systemName: "gearshape.fill")
//                                .foregroundColor(.green)
//                                .padding(8)
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                        
//                        Button(action: {
//                            print("Download tapped")
//                        }) {
//                            Image(systemName: "arrow.down.circle.fill")
//                                .foregroundColor(.green)
//                                .padding(8)
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                        
//                        Button(action: {
//                            print("Map tapped")
//                        }) {
//                            Image(systemName: "map.fill")
//                                .foregroundColor(.green)
//                                .padding(8)
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                    }
//                }
//            }
//    
//            .background(
//                Color.clear // transparent color background
//                    .contentShape(Rectangle())
//            )
//        }
//    }
//    
//    // 自定义图标按钮样式
//    struct IconWithBackground: View {
//        var systemName: String
//        var backgroundColor: Color
//
//        var body: some View {
//            Image(systemName: systemName)
//                .font(.system(size: 15))
//                .foregroundColor(backgroundColor == .white ? .green : .white)
//                .padding()
//                .background(backgroundColor)
//                .clipShape(Circle())
//                .shadow(radius: 4)
//        }
//    }
//}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
