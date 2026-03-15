import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    // ROOT GEOMETRY OBSERVERS (FORCES REDRAWS)
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    @AppStorage("iconSize") private var iconSize: Double = 14.0
    @AppStorage("dropDepth") private var dropDepth: Double = 40.0
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id("\(arcSpread)_\(dropDepth)_\(iconSize)") // RUTHLESS GEOMETRY INVALIDATION
            
            VStack(spacing: 0) {
                // The Main Droplet Pill
                ZenithPillView(isHovering: isHovering, isPulsing: isPulsing)
            }
        }
        .frame(width: 800, height: 400)
        .padding(.top, 40) // PUSH DOWN TO CLEAR PHYSICAL NOTCH
        .contentShape(Rectangle()) // MASSIVE HITBOX WALL
        .background(Color.black.opacity(0.001)) // FIX HITBOX TRANSPARENCY BUG AND KEEP WINDOW ACTIVE
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
