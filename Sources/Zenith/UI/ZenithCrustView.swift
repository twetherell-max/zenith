import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                HStack(spacing: 60) { // REFINED SPACING
                    // Button 1 (Left) - Appears slightly up and left
                    CrustButton(id: 1, icon: "command", isHovering: isHovering, offset: CGSize(width: -70, height: 20)) {
                        print("Button 1 (Command) tapped")
                    }
                    
                    // Button 2 (Center) - Appears straight down
                    CrustButton(id: 2, icon: "cpu", isHovering: isHovering, offset: CGSize(width: 0, height: 50)) {
                        print("Button 2 (CPU) tapped")
                    }
                    
                    // Button 3 (Right) - Appears slightly up and right
                    CrustButton(id: 3, icon: "flowchart", isHovering: isHovering, offset: CGSize(width: 70, height: 20)) {
                        print("Button 3 (Flowchart) tapped")
                    }
                }
                .frame(width: 400, height: 100)
                .zIndex(5) // FORCE FOREGROUND
            }
            .frame(width: 400, height: 250) // EXPANDED HEIGHT
            .padding(.top, 50)
        }
        .frame(width: 800, height: 400)
    }
}

struct CrustButton: View {
    let id: Int
    let icon: String // RESTORED ICON PARAM
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial) // GLASSMORPHISM
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 0.5)) // THIN BORDER
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 60, height: 60) // EXPLICIT BUTTON FRAME
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        .offset(isHovering ? offset : .zero) // SLIDE ANIMATION
        .scaleEffect(isHovering ? 1.0 : 0.01) // POP ANIMATION
        .opacity(isHovering ? 1.0 : 0.0) // FADE ANIMATION
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isHovering)
    }
}
