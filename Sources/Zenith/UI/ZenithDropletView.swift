import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    // ROOT GEOMETRY MEMORY PIPELINE (Observes state instantly instead of polling disk)
    @EnvironmentObject var state: ZenithState
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // FORCE COMPLETE VIEW RECONSTRUCTION ON LIVE COMBINE UPDATES
        .id("zenith-main-view") 
        .onChange(of: state.arcSpread) { _ in } // LIVE REDRAW TRIGGER
        .onChange(of: state.dropDepth) { _ in }
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
