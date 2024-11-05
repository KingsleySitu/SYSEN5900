import SwiftUI

struct LocationRow: View {
    var iconName: String
    var title: String
    var address: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.green)
                .frame(width: 30, height: 30)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                    .bold()
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

