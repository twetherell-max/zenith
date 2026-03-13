import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack {
            // Button 1 (Left)
            CrustButton(id: 1, icon: "command", isHovering: isHovering, offset: CGSize(width: -70, height: 30)) {
                print("Button 1 (Command) tapped")
            }
            
            // Button 2 (Center)
            CrustButton(id: 2, icon: "cpu", isHovering: isHovering, offset: CGSize(width: 0, height: 60)) {
                print("Button 2 (CPU) tapped")
            }
            
            // Button 3 (Right)
            CrustButton(id: 3, icon: "flowchart", isHovering: isHovering, offset: CGSize(width: 70, height: 30)) {
                print("Button 3 (Flowchart) tapped")
            }
        }
        .frame(width: 800, height: 400)
        .opacity(1.0) // FORCE OPAQUE
    }
}

struct CrustButton: View {
    let id: Int
    let icon: String
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.7)) // SOLID BLACK FALLBACK
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5) // HEAVY SHADOW
                    .overlay(Circle().stroke(Color.white, lineWidth: 2)) // THICK WHITE BORDER
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold)) // BOLD ICON
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        .offset(isHovering ? offset : .zero)
        .scaleEffect(isHovering ? 1.0 : 0.01)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering)
    }
}
