import SwiftUI

struct AQIReferenceBar: View {
    private let gradientColors = [
        Color.green,  // Best air quality
        Color.yellow, // Moderate
        Color.orange, // Unhealthy
        Color.red     // Very unhealthy
    ]

    var body: some View {
        VStack {
            // Top label for 100
            Text("100")
                .font(.caption)
                .foregroundColor(.black)

            // Gradient bar
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 20, height: 150) // Adjust bar dimensions
            .cornerRadius(10) // Rounded edges

            // Bottom label for 0
            Text("0")
                .font(.caption)
                .foregroundColor(.black)
        }
        .padding(.vertical, 10) // Adjust overall vertical padding
    }
}
