import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    @State private var hoveredButton: Int? = nil // TRACK HOVER STATE
    
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
                    CrustButton(id: 1, icon: "command", tooltip: "Open Downloads", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: -100, height: -40)) {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ("~/Downloads" as NSString).expandingTildeInPath)
                    }
                    
                    // Button 2 (Center) - Activity Monitor
                    CrustButton(id: 2, icon: "cpu", tooltip: "Activity Monitor", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: 0, height: 20)) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    // Button 3 (Right) - Mission Control
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Mission Control", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: 100, height: -40)) {
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2)) // SOLID FALLBACK
                    .background(Circle().fill(.thickMaterial)) // HEAVY GLASS
                    .frame(width: 50, height: 50) // SMALLER ORB
                    .shadow(color: hoveredButton == id ? .white : .black.opacity(0.8), radius: hoveredButton == id ? 15 : 10) // DYNAMIC GLOW
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 0.5)) // THIN BORDER
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold)) // SMALLER, BREATHABLE ICON
                    .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) // ICON BRIGHTNESS
            }
            .contextMenu { // ADD MENUBAR EXACTLY ON THE BUTTON ORB
                let _ = print(">>> Right-click detected on button \(id)")
                Button("Settings...") {
                    let settings = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                        styleMask: [.titled, .closable, .miniaturizable],
                        backing: .buffered,
                        defer: false
                    )
                    settings.center()
                    settings.title = "Zenith Preferences"
                    settings.makeKeyAndOrderFront(nil)
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
        .frame(width: 50, height: 50) // EXPLICIT BUTTON FRAME
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        .offset(isHovering ? offset : .zero) // SLIDE ONLY
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering) // ORBITAL ENTRANCE BOUNCE
        .scaleEffect(hoveredButton == id ? 1.2 : 1.0) // JUICY SCALING
        .blur(radius: (hoveredButton != nil && hoveredButton != id) ? 0.5 : 0) // DEFOCUS OTHERS
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hoveredButton) // SPRING ANIMATION
        .onHover { isHovered in
            hoveredButton = isHovered ? id : nil
        }
        .help(tooltip) // MACOS TOOLTIP
    }
}
