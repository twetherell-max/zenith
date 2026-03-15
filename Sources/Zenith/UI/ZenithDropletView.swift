import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    // ROOT GEOMETRY MEMORY PIPELINE (Observes state instantly instead of polling disk)
    @EnvironmentObject var state: ZenithState
    
    // DEBUG ID: If you see two different numbers, there are two windows.
    private let debugID = Int.random(in: 1...100)
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: isHovering)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // DEBUG LABEL
            Text("ID: \(debugID)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 2)
        }
        // FORCE COMPLETE VIEW RECONSTRUCTION ON LIVE COMBINE UPDATES
        .id("zenith-main-view") 
        .onChange(of: state.arcSpread) { _ in } // LIVE REDRAW TRIGGER
        .onChange(of: state.dropDepth) { _ in }
        .frame(width: 800, height: 400)
        .padding(.top, 40) // PUSH DOWN TO CLEAR PHYSICAL NOTCH
        .contentShape(Rectangle()) // MASSIVE HITBOX WALL
        .background(Color.black.opacity(0.001)) // FIX HITBOX TRANSPARENCY BUG AND KEEP WINDOW ACTIVE
        .onAppear {
            print(">>> DROPLET VIEW APPEARED: Refreshing positions...")
            if state.arcSpread == 0 { state.arcSpread = 80 }
            state.load() // FORCE INITIAL SYNC
        }
    }
    
    private func openSettingsWindow() {
        print(">>> OPENING SETTINGS WINDOW")
        // FORCE APP TO SHOW IN DOCK AND GAIN FOCUS
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        ZenithSettingsWindow.show()
    }
}
