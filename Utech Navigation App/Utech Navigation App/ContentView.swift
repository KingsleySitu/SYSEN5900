//
//  ContentView.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on 10/10/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // save search keyword
    @State private var isSearching: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("backgroundImage")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    // searchbar
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
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
            .sheet(isPresented: $isSearching) {
                // refer to SearchResultsView
                SearchResultsView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 150)
                        Button(action: {
                            print("Settings tapped")
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            print("Download tapped")
                        }) {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            print("Map tapped")
                        }) {
                            Image(systemName: "map.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                }
            }
    
            .background(
                Color.clear // transparent color background
                    .contentShape(Rectangle())
            )
        }
    }
    
    // 自定义图标按钮样式
    struct IconWithBackground: View {
        var systemName: String
        var backgroundColor: Color

        var body: some View {
            Image(systemName: systemName)
                .font(.system(size: 15))
                .foregroundColor(backgroundColor == .white ? .green : .white)
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
