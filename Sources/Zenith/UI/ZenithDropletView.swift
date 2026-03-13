import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            /* Hiding Droplet for Visibility Debug
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
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
                    .opacity(0.8) // DEBUG OPACITY
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isPulsing)
            }
            .zIndex(1)
            */
            
            // Radial Menu (The Crust) - ON TOP
            ZenithCrustView(isHovering: isHovering)
                .zIndex(999)
        }
        .frame(width: 800, height: 400)
    }
}
