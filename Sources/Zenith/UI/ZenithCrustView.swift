import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    @State private var hoveredButton: Int? = nil // TRACK HOVER STATE
    
    // LIVE GEOMETRY & THEME BINDINGS
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    @AppStorage("iconSize") private var iconSize: Double = 14.0
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    
    var body: some View {
        let _ = print(">>> BUTTONS SHOULD BE VISIBLE NOW")
        
        ZStack(alignment: .top) { // ALIGN TO TOP
            // THE DROPLET BRIDGE
            Rectangle()
                .fill(Color.black)
                .frame(width: 150, height: 40)
                .offset(y: -40) // REACH UP TO THE PHYSICAL NOTCH
            
            VStack {
                HStack(spacing: 60) { // REFINED SPACING
                    // Button 1 (Left) - Open Downloads
                    CrustButton(id: 1, icon: "command", tooltip: "Open Downloads", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: -(arcSpread + iconSize), height: -(arcSpread / 4)), iconSize: iconSize, isDarkGlass: isDarkGlass) {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ("~/Downloads" as NSString).expandingTildeInPath)
                    }
                    
                    // Button 2 (Center) - Activity Monitor
                    CrustButton(id: 2, icon: "cpu", tooltip: "Activity Monitor", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: 0, height: 20), iconSize: iconSize, isDarkGlass: isDarkGlass) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    // Button 3 (Right) - Mission Control
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Mission Control", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: (arcSpread + iconSize), height: -(arcSpread / 4)), iconSize: iconSize, isDarkGlass: isDarkGlass) {
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
    let isHovering: Bool
    @Binding var hoveredButton: Int?
    let offset: CGSize
    let iconSize: Double // LIVE SIZE
    let isDarkGlass: Bool // LIVE THEME
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2)) // SOLID FALLBACK
                    .background(Circle().fill(.thickMaterial)) // HEAVY GLASS
                    .frame(width: iconSize * 3.0, height: iconSize * 3.0) // ELASTIC ORB DYNAMICS
                    .shadow(color: hoveredButton == id ? .white : .black.opacity(0.8), radius: hoveredButton == id ? 15 : 10) // DYNAMIC GLOW
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 0.5)) // THIN BORDER
                
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold)) // DYNAMIC SIZE
                    .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) // ICON BRIGHTNESS
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
        .offset(isHovering ? offset : .zero) // SLIDE ONLY
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering) // ORBITAL ENTRANCE BOUNCE
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
