//
//  LocationRow.swift
//  Utech Navigation App
//
//  Created by Kingsley Situ on [Date]
//

import SwiftUI

struct LocationRow: View {
    var iconName: String
    var title: String
    var address: String

    var body: some View {
        HStack {
            // Icon with a circular background
            Image(systemName: iconName)
                .foregroundColor(.green)
                .frame(width: 30, height: 30)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            // Text information stacked vertically
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                    .bold()
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)    // Ensure multiple lines are left-aligned
                    .lineLimit(nil)                     // No limit to the number of lines
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
            }
            
            Spacer() // Pushes content to the left
        }
        .padding(.vertical, 5) // Vertical padding for spacing
    }
}
