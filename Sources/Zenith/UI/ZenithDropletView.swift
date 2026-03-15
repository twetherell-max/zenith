import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    // ROOT GEOMETRY MEMORY PIPELINE (Observes state instantly instead of polling disk)
    @EnvironmentObject var state: ZenithState
    
    // DEBUG ID: If you see two different numbers, there are two windows.
    private let debugID = Int.random(in: 1...100)
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private var effectivelyExpanded: Bool {
        isHovering || state.isSettingsOpen
    }
    
    var body: some View {
        ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: effectivelyExpanded)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // DEBUG LABEL
            Text("ID: \(debugID)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 2)
        }
        .contentShape(Rectangle()) // STABILIZE HITBOX: Area doesn't shrink when buttons move
        // FORCE COMPLETE VIEW RECONSTRUCTION ON LIVE COMBINE UPDATES
        .id("zenith-main-view") 
        .onChange(of: state.arcSpread) { _ in } // LIVE REDRAW TRIGGER
        .onChange(of: state.dropDepth) { _ in }
        .onChange(of: state.isSettingsOpen) { isOpen in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Expansion is now handled via effectivelyExpanded computed property
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isHovering = hovering
            }
        }
        .frame(width: 800, height: 400)
        .contentShape(Rectangle()) // MASSIVE HITBOX WALL
        .background(Color.black.opacity(0.001)) // FIX HITBOX TRANSPARENCY BUG AND KEEP WINDOW ACTIVE
        .onReceive(timer) { _ in state.objectWillChange.send() }
    }
    
    private func openSettingsWindow() {
        // FORCE DOCK ICON TO ALLOW WINDOWS TO REACH FRONT
        NSApp.setActivationPolicy(.regular)
        
        print(">>> OPENING SETTINGS WINDOW")
        NSApp.activate(ignoringOtherApps: true)
        
        ZenithSettingsWindow.show()
    }
}
