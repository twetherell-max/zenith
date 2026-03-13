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
                    .fill(.clear)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.2))) // SOLID FALLBACK
                    .shadow(color: .blue.opacity(0.5), radius: 10) // GLOW DEBUG
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
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
