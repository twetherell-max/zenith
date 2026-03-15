import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    @EnvironmentObject var state: ZenithState
    
    @State private var hoveredButton: Int? = nil // TRACK HOVER STATE
    
    // LIVE GEOMETRY & THEME BINDINGS
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    @AppStorage("iconSize") private var iconSize: Double = 14.0
    @AppStorage("dropDepth") private var dropDepth: Double = 40.0
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    @AppStorage("isSettingsOpen") private var isSettingsOpen: Bool = false
    
    // VISIBILITY SYNC
    private var isExpanded: Bool {
        isHovering || isSettingsOpen
    }
    
    // Expansion Multiplier for rigid physics
    private var expansionAmount: Double {
        isExpanded ? 1.0 : 0.0
    }
    
    // RADIUS ENGINE
    private var radius: Double {
        state.arcSpread
    }
    
    // POLAR COORDINATE MATH (RADIANS)
    // Left: -45 degrees (-45 * pi / 180)
    private var leftOffset: CGSize {
        let radians = -45.0 * .pi / 180.0
        let x = sin(radians) * state.arcSpread
        let y = state.dropDepth - (state.arcSpread * 0.3)
        return CGSize(
            width: x * expansionAmount,
            height: -100 + (expansionAmount * (y + 100))
        )
    }
    
    // Center: 0 degrees
    private var middleOffset: CGSize {
        let y = state.dropDepth
        return CGSize(
            width: 0,
            height: -100 + (expansionAmount * (y + 100))
        )
    }
    
    // Right: 45 degrees
    private var rightOffset: CGSize {
        let radians = 45.0 * .pi / 180.0
        let x = sin(radians) * state.arcSpread
        let y = state.dropDepth - (state.arcSpread * 0.3)
        return CGSize(
            width: x * expansionAmount,
            height: -100 + (expansionAmount * (y + 100))
        )
    }
    
    var body: some View {
        let _ = print(">>> BUTTONS SHOULD BE VISIBLE NOW")
        
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                ZStack { // POLAR COORDINATE ORIGIN (0,0)
                    // Button 1 (Left) - Open Downloads
                    CrustButton(id: 1, icon: "folder", tooltip: "Downloads", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: leftOffset, iconSize: state.iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                        NSWorkspace.shared.open(downloadsURL)
                    }
                    .zIndex(0)
                    
                    // Button 2 (Center) - App Settings
                    CrustButton(id: 2, icon: "gearshape.fill", tooltip: "Settings", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: middleOffset, iconSize: state.iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        // Action handled in button for now, but can be augmented
                        let _ = print("Settings opened")
                    }
                    .zIndex(1)
                    
                    // Button 3 (Right) - Mission Control
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Mission Control", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: rightOffset, iconSize: state.iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.exposelauncher") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .zIndex(0)
                }
                .frame(width: 400, height: 100)
                .zIndex(5) // FORCE FOREGROUND
            }
            .frame(width: 400, height: 250) // EXPANDED HEIGHT
            .padding(.top, 50)
            .background(Color.black.opacity(0.01)) // GHOST BACKGROUND TO KEEP WINDOW ACTIVE
        }
        .frame(width: 800, height: 400)
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
                    
                    if id == 2 && isSettingsOpen {
                        Text("OPEN")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
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
