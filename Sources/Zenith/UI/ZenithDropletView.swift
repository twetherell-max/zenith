import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                // The Main Droplet Pill
                ZenithPillView(isHovering: isHovering, isPulsing: isPulsing)
            }
        }
        .frame(width: 800, height: 400)
        .padding(.top, 40) // PUSH DOWN TO CLEAR PHYSICAL NOTCH
        .background(Color.white.opacity(0.01)) // FIX HITBOX TRANSPARENCY BUG
    }
    
    private func openSettingsWindow() {
        print(">>> OPENING SETTINGS WINDOW")
        ZenithSettingsWindow.show()
    }
}

struct ZenithPillView: View {
    let isHovering: Bool
    let isPulsing: Bool
    
    var body: some View {
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
