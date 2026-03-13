import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.cyan, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 60, height: 35)
                .shadow(color: .cyan.opacity(0.8), radius: 8)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                // The droplet is at the bottom. 
                // We'll peek it by 5px by positioning the window correctly.
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isPulsing)
        }
        .frame(width: 200, height: 80)
    }
}
