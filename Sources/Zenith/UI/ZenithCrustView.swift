import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    @State private var hoveredButton: Int? = nil // TRACK HOVER STATE
    
    var body: some View {
        let _ = print(">>> BUTTONS SHOULD BE VISIBLE NOW")
        
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                HStack(spacing: 60) { // REFINED SPACING
                    // Button 1 (Left) - Appears slightly up and left
                    CrustButton(id: 1, icon: "command", tooltip: "Open Applications", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: -70, height: 20)) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications"))
                    }
                    
                    // Button 2 (Center) - Appears straight down
                    CrustButton(id: 2, icon: "cpu", tooltip: "Activity Monitor", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: 0, height: 50)) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    // Button 3 (Right) - Appears slightly up and right
                    CrustButton(id: 3, icon: "flowchart", tooltip: "Zen Mode", isHovering: isHovering, hoveredButton: $hoveredButton, offset: CGSize(width: 70, height: 20)) {
                        print("Zen Active")
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
                    .frame(width: 60, height: 60)
                    .shadow(color: hoveredButton == id ? .white : .black.opacity(0.8), radius: hoveredButton == id ? 15 : 10) // DYNAMIC GLOW
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 0.5)) // THIN BORDER
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) // ICON BRIGHTNESS
            }
        }
        .frame(width: 60, height: 60) // EXPLICIT BUTTON FRAME
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        .offset(isHovering ? offset : .zero) // SLIDE ONLY
        .scaleEffect(hoveredButton == id ? 1.2 : 1.0) // JUICY SCALING
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hoveredButton) // SPRING ANIMATION
        .onHover { isHovered in
            hoveredButton = isHovered ? id : nil
        }
        .help(tooltip) // MACOS TOOLTIP
    }
}
