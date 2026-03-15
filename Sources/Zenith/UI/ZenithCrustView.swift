import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    @ObservedObject var state = ZenithState.shared
    
    @State private var hoveredButton: Int? = nil // TRACK HOVER STATE
    
    // REDUNDANT WRAPPERS REMOVED - DIRECT STATE BINDING ENFORCED
    private var isExpanded: Bool {
        isHovering || state.isSettingsOpen
    }
    
    // REDUNDANT WRAPPERS REMOVED - DIRECT STATE BINDING ENFORCED
    private func getPosition(for id: Int) -> CGPoint {
        if !isExpanded {
            return CGPoint(x: 0, y: -100)
        }
        
        // SMILE CURVE ENGINE: Upward spread (abs * -0.2)
        let xOffset = CGFloat(id - 2) * state.arcSpread
        let yPos = (abs(xOffset) * -0.2) + state.dropDepth
        
        return CGPoint(x: xOffset, y: yPos)
    }
    
    var body: some View {
        let _ = print("NOTCH DRAWING WITH SPREAD: \(state.arcSpread)")
        
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                ZStack { // ABSOLUTE COORDINATE ORIGIN
                    // Button 1 (Left) - Open Downloads
                    CrustButton(id: 1, icon: "folder", tooltip: "Downloads", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                        NSWorkspace.shared.open(downloadsURL)
                    }
                    .offset(x: getPosition(for: 1).x, y: getPosition(for: 1).y)
                    .zIndex(1)
                    
                    CrustButton(id: 2, icon: "gearshape.fill", tooltip: "Settings", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        NSApp.activate(ignoringOtherApps: true)
                        AppDelegate.shared?.showSettings()
                    }
                    .padding(10) // EXPANDED HIT-REGION
                    .contentShape(Rectangle()) // BRAIN-DEAD RELIABLE HITBOX
                    .offset(x: getPosition(for: 2).x, y: getPosition(for: 2).y)
                    .zIndex(2)
                    
                    // Button 3 (Right) - Mission Control
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Mission Control", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.exposelauncher") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .offset(x: getPosition(for: 3).x, y: getPosition(for: 3).y)
                    .zIndex(1)
                }
                .frame(width: 800, height: 100)
                .zIndex(5) // FORCE FOREGROUND
            }
            .frame(width: 800, height: 250) // EXPANDED HEIGHT
            .background(Color.black.opacity(0.01)) // GHOST BACKGROUND TO KEEP WINDOW ACTIVE
        }
        .frame(width: 800, height: 200)
    }
}

struct CrustButton: View {
    let id: Int
    let icon: String
    let tooltip: String
    let isExpanded: Bool // LIVE PREVIEW SYNC
    @Binding var hoveredButton: Int?
    let offset: CGSize
    let iconSize: Double // LIVE SIZE
    let isDarkGlass: Bool // LIVE THEME
    let isSettingsOpen: Bool // LIVE INDICATOR
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2)) // SOLID FALLBACK
                    .background(Circle().fill(.thickMaterial)) // HEAVY GLASS
                    .frame(width: iconSize * 2.2, height: iconSize * 2.2) // VISUAL SIZE
                    .shadow(color: hoveredButton == id ? .white : .black.opacity(0.8), radius: hoveredButton == id ? 15 : 10) // DYNAMIC GLOW
                    .overlay(
                        Circle()
                            .stroke((id == 2 && isSettingsOpen) ? Color.white : .white.opacity(0.4), lineWidth: (id == 2 && isSettingsOpen) ? 2 : 0.5)
                            .shadow(color: (id == 2 && isSettingsOpen) ? .white : .clear, radius: 5)
                    ) // LIVE PREVIEW GLOW RING
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .semibold)) // DYNAMIC SIZE
                        .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) // ICON BRIGHTNESS
                        .frame(width: icon == "gearshape.fill" ? 40 : nil, height: icon == "gearshape.fill" ? 40 : nil) // HITBOX PROTECTION
                    
                    if id == 2 && isSettingsOpen {
                        Text("OPEN")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: icon == "gearshape.fill" ? 60 : nil, height: icon == "gearshape.fill" ? 60 : nil) // MASSIVE GEAR HITBOX
                .contentShape(Rectangle()) // FORCE RECTANGULAR HIT-TEST AREA FOR GEAR
            }
            .environment(\.colorScheme, isDarkGlass ? .dark : .light) // LIVE MATERIAL THEME
        }
        .frame(width: iconSize * 1.5, height: iconSize * 1.5) // TIGHTER HITBOX
        .contentShape(Circle()) // STRICT CIRCULAR HITBOX
        .offset(offset) // UNIFIED ABSOLUTE MATH
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isExpanded) // UNIFIED LAYOUT ANIMATION
        .scaleEffect(hoveredButton == id ? 1.2 : 1.0) // JUICY SCALING
        .blur(radius: (hoveredButton != nil && hoveredButton != id) ? 0.5 : 0) // DEFOCUS OTHERS
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hoveredButton) // SPRING ANIMATION
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: iconSize) // ELASTIC RESIZING
        .onHover { isHovered in
            hoveredButton = isHovered ? id : nil
        }
        .help(tooltip) // MACOS TOOLTIP
    }
}
