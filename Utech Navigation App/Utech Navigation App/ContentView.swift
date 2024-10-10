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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // save search keyword
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                // searchbar

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by location...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    Spacer()
                    Image(systemName: "mic.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(25)
                .padding(.horizontal)
            }
            .navigationBarTitle("Utech Navigation App", displayMode: .inline)
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
                    .onTapGesture {
                        hideKeyboard()
                    }
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 自定义图标按钮样式
    struct IconWithBackground: View {
        var systemName: String
        var backgroundColor: Color

        var body: some View {
            Image(systemName: systemName)
                .font(.system(size: 24))
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
