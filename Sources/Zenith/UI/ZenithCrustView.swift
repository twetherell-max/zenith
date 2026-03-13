import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack {
            // Button 1 (Left): Command
            CrustButton(icon: "command", isHovering: isHovering, offset: CGSize(width: -60, height: 40)) {
                print("Button 1 (Command) tapped")
            }
            
            // Button 2 (Center): CPU
            CrustButton(icon: "cpu", isHovering: isHovering, offset: CGSize(width: 0, height: 70)) {
                print("Button 2 (CPU) tapped")
            }
            
            // Button 3 (Right): Flowchart
            CrustButton(icon: "flowchart", isHovering: isHovering, offset: CGSize(width: 60, height: 40)) {
                print("Button 3 (Flowchart) tapped")
            }
        }
    }
}

struct CrustButton: View {
    let icon: String
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .offset(isHovering ? offset : .zero)
        .scaleEffect(isHovering ? 1.0 : 0.0)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovering)
    }
}
