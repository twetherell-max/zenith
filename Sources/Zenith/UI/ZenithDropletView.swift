import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        ZStack {
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .offset(y: 50)
            
            VStack(spacing: 0) {
                Spacer()
                    .allowsHitTesting(false)
                
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
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isPulsing)
            }
        }
        .frame(width: 600, height: 300)
    }
}
