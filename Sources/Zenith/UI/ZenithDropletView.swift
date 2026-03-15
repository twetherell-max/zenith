import SwiftUI

struct ZenithDropletView: View {
    @Binding var isPulsing: Bool
    
    @ObservedObject var state = ZenithState.shared
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let _ = print("NOTCH DRAWING WITH SPREAD: \(state.arcSpread)")
        
        return ZStack(alignment: .top) { // PIN TO TOP
            // Radial Menu (The Crust) - Behind the droplet
            ZenithCrustView(isHovering: state.isExpanded || state.isSettingsOpen)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // DEBUG LABEL: SHARED STATE PROOF
            Text("BRAIN ID: \(state.debugID)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 2)
        }
        .contentShape(Rectangle()) // PIN POINT HOVER DETECTION
        .contentShape(Rectangle()) // STABILIZE HITBOX: Area doesn't shrink when buttons move
        // FORCE COMPLETE VIEW RECONSTRUCTION ON LIVE COMBINE UPDATES
        .id("zenith-main-view") 
        .onChange(of: state.arcSpread) { _ in } // LIVE REDRAW TRIGGER
        .onChange(of: state.dropDepth) { _ in }
        .onChange(of: state.isSettingsOpen) { isOpen in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if isOpen {
                    state.isExpanded = true
                }
            }
        }
        .onHover { hovering in
            // GATEKEEPER LOGIC: If settings are open, do NOT change expansion based on mouse
            if !state.isSettingsOpen {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    state.isExpanded = hovering
                }
            }
        }
        .frame(width: 800, height: 200)
        .contentShape(Rectangle()) // MASSIVE HITBOX WALL
        .background(Color.black.opacity(0.001)) // FIX HITBOX TRANSPARENCY BUG AND KEEP WINDOW ACTIVE
        .onReceive(timer) { _ in state.objectWillChange.send() }
    }
    
    private func openSettingsWindow() {
        // FORCE DOCK ICON TO ALLOW WINDOWS TO REACH FRONT
        NSApp.setActivationPolicy(.regular)
        
        print(">>> OPENING SETTINGS WINDOW")
        NSApp.activate(ignoringOtherApps: true)
        
        AppDelegate.shared?.showSettings()
    }
}
