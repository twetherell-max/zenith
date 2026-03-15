import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    // ROOT GEOMETRY OBSERVERS (FORCES REDRAWS)
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    @AppStorage("iconSize") private var iconSize: Double = 14.0
    @AppStorage("dropDepth") private var dropDepth: Double = 50.0
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .id("zenith-main-view") // FORCE COMPLETE VIEW RECONSTRUCTION
        .onChange(of: arcSpread) { _ in } // LIVE REDRAW TRIGGER
        .onChange(of: dropDepth) { _ in }
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
