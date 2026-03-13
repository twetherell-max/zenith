import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        ZStack {
            // Radial Menu (The Crust)
            ZenithCrustView(isHovering: isHovering)
                .offset(y: 10) // Align center of expansion with notch
            
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
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isPulsing)
            }
        }
        .frame(width: 200, height: 120) // Increased height for radial menu
    }
}
