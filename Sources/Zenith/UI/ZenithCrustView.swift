import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
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
        arcSpread
    }
    
    // POLAR COORDINATE MATH (RADIANS)
    // Left: 135 degrees (135 * pi / 180)
    private var leftOffset: CGSize {
        let radians = 135.0 * .pi / 180.0
        let targetDrop = dropDepth - (radius * sin(radians))
        return CGSize(
            width: (radius * cos(radians)) * expansionAmount,
            height: -100 + (expansionAmount * (targetDrop + 100))
        )
    }
    
    // Center: 90 degrees (90 * pi / 180)
    private var middleOffset: CGSize {
        return CGSize(
            width: 0,
            height: -100 + (expansionAmount * (dropDepth + 100))
        )
    }
    
    // Right: 45 degrees (45 * pi / 180)
    private var rightOffset: CGSize {
        let radians = 45.0 * .pi / 180.0
        let targetDrop = dropDepth - (radius * sin(radians))
        return CGSize(
            width: (radius * cos(radians)) * expansionAmount,
            height: -100 + (expansionAmount * (targetDrop + 100))
        )
    }
    
    var body: some View {
        let _ = print(">>> BUTTONS SHOULD BE VISIBLE NOW")
        
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                ZStack { // POLAR COORDINATE ORIGIN (0,0)
                    // Button 1 (Left) - Open Downloads
                    CrustButton(id: 1, icon: "command", tooltip: "Open Downloads", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: leftOffset, iconSize: iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ("~/Downloads" as NSString).expandingTildeInPath)
                    }
                    
                    // Button 2 (Center) - Activity Monitor
                    CrustButton(id: 2, icon: "cpu", tooltip: "Activity Monitor", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: middleOffset, iconSize: iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    // Button 3 (Right) - Mission Control
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Mission Control", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: rightOffset, iconSize: iconSize, isDarkGlass: isDarkGlass, isSettingsOpen: isSettingsOpen) {
                        NSWorkspace.shared.launchApplication("Mission Control")
                    }
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
                    .frame(width: iconSize * 3.0, height: iconSize * 3.0) // ELASTIC ORB DYNAMICS
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
            .contextMenu { // ADD MENUBAR EXACTLY ON THE BUTTON ORB
                let _ = print(">>> Right-click detected on button \(id)")
                Button("Settings...") {
                    ZenithSettingsWindow.show()
                }
                Button("Check for Updates") {
                    print("Check Updates")
                }
                Divider()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .frame(width: iconSize * 3.0, height: iconSize * 3.0) // ELASTIC EXPLICIT FRAME
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
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
