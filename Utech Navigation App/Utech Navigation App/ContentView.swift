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
    @State private var searchText: String = ""
    @State private var showSearchResults: Bool = false

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
                    Button(action: {
                        showSearchResults = true
                    }) {
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
                        .background(Color(.systemGray6).opacity(0.8))
                        .cornerRadius(25)
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                }
            }
            .sheet(isPresented: $showSearchResults) {
                SearchResultsView() // refer to SearchResultsView
            }
            .toolbar {
                // icon in a column
                ToolbarItem(placement: .navigationBarTrailing) {
                    VStack(spacing: 15) { // space from top
                        Spacer().frame(height: 150)
                        Button(action: {
                            //
                        }) {
                            IconWithBackground(systemName: "person.crop.circle", backgroundColor: .green)
                        }

                        Button(action: {
                            // 下载图标功能
                        }) {
                            IconWithBackground(systemName: "arrow.down.circle", backgroundColor: .white)
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
