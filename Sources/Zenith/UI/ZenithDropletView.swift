import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.cyan, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 200, height: 60)
            .shadow(color: .cyan.opacity(0.8), radius: isHovering ? 15 : 5)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .offset(y: isHovering ? 10 : -70)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering)
            .animation(.easeInOut(duration: 0.2), value: isPulsing)
    }
}


