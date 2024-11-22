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
    
    @State private var selectedTransportMode: String = "car" // 默认选中汽车
    
    @State private var isDirectionsMode: Bool = false // 控制弹窗模式
    
    @State private var isShowingBottomSheet: Bool = false // 控制弹窗显示
    @State private var currentMarkerDetails: String? = nil // 标记的地址详情
    
    // 当前地址的标记信息
    @State private var currentMarker: (coordinate: CLLocationCoordinate2D, title: String)? = nil
    
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
            // 主地图内容
            if locationManager.isLocationReady {
                // 主地图视图
                mapView
                    .opacity(isShowingLoadingScreen ? 0 : 1) // 地图淡入效果
                    .animation(.easeInOut(duration: 0.5), value: isShowingLoadingScreen)
                
                // 叠加层控制
                controlsOverlay
                    .opacity(isShowingLoadingScreen ? 0 : 1) // 控件淡入效果
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isShowingLoadingScreen) // 控件淡入稍有延迟
            }
            
            // 底部弹窗
            VStack {
                Spacer() // 将弹窗推到底部
                if isShowingBottomSheet {
                    bottomSheet
                        .onTapGesture {
                            // 点击关闭弹窗
                            isShowingBottomSheet = false
                        }
                }
            }
            .edgesIgnoringSafeArea(.bottom) // 确保弹窗覆盖到屏幕底部的安全区域
            
            // 加载屏幕叠加层
            if isShowingLoadingScreen {
                LoadingView {
                    // 加载动画完成回调
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingLoadingScreen = false
                    }
                }
                .transition(.opacity)
            }
        }
        // Present search sheet when isSearching is true
        .sheet(isPresented: $isSearching) {
            SearchResultsView { coordinate, address in
                // 更新地图位置
                withAnimation(.easeInOut(duration: 1.0)) {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                    ))
                    // 更新标记信息
                    currentMarker = (coordinate, address)
                    currentMarkerDetails = "Air Quality Index: 100" // 替换为实际地址详情
                    isShowingBottomSheet = true // 显示底部弹窗
                }
                isSearching = false // 关闭搜索视图
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // 用户当前位置标记
            if let userLocation = locationManager.userLocation {
                Annotation("", coordinate: userLocation.coordinate) {
                    locationAnnotation
                }
            }
            
            // 当前选中地址的标记
            if let marker = currentMarker {
                Annotation(marker.title, coordinate: marker.coordinate) {
                    markerAnnotation()
                }
            }
        }
        .mapControls {
            MapCompass()
        }
        .mapStyle(isAirQualityMap ? .imagery : .standard)
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .onAppear {
            if let location = locationManager.userLocation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                ))
            }
        }
    }
    
    private func markerAnnotation() -> some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(.red)
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
    
    // MARK: - Bottom Pop Out
    private var bottomSheet: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer() // 将按钮推到右侧
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) { // 使用丝滑动画
                        isShowingBottomSheet = false
                        isDirectionsMode = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing)
            .padding(.top)
            
            if isDirectionsMode {
                directionsContent
            } else {
                locationDetailsContent
            }
        }
        .background(RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5))
        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
        .padding(.horizontal)
        .padding(.bottom, 45)
        .transition(.move(edge: .bottom)) // 设置从底部滑入滑出
        .animation(.easeInOut(duration: 0.3), value: isShowingBottomSheet)
    }
    
    private var locationDetailsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let marker = currentMarker {
                Text(marker.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 显示空气质量信息
                Text("Air Quality Index: Moderate (100)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider() // 分割线
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) { // 添加切换动画
                        isDirectionsMode = true
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
        }
        .padding()
        .transition(.move(edge: .trailing)) // 从右侧滑入
    }
    
    private var directionsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let marker = currentMarker {
                // 显示当前标记的标题
                Text(marker.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 显示当前标记的子标题
                Text("New York, NY")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // 交通方式图标
            HStack(spacing: 20) {
                Spacer()
                ForEach(["car", "figure.walk", "bus", "tram", "bicycle"], id: \.self) { mode in
                    Button(action: {
                        selectedTransportMode = mode
                    }) {
                        Image(systemName: mode)
                            .foregroundColor(selectedTransportMode == mode ? .green : .gray)
                            .font(.title2)
                            .padding(8)
                            .background(selectedTransportMode == mode ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            
            // 路线详情
            VStack(alignment: .leading, spacing: 5) {
                Text("35 min (3.5 mi)")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text("High traffic • No tolls")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // 开始导航按钮
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
