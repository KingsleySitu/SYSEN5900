import SwiftUI


struct LoadingView: View {
    // Animation state for fade transition
    @State private var isLoading = true
    
    // References to manage view transitions
    let onLoadingComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Green background
            Color.green
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Centered image
                Image("LoadingLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            }
            .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        }
        // Fade out animation when loading completes
        .opacity(isLoading ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: isLoading)
        // Start transition after a delay
        .onAppear {
            // Delay the transition by 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Start fade out animation
                withAnimation {
                    isLoading = false
                }
                // Notify parent view that loading is complete
                onLoadingComplete()
            }
        }
    }
}

// Preview provider
//#Preview {
//    LoadingView()
//}
