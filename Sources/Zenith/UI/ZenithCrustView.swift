import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Button 1 (Left): Command
            CrustButton(icon: "command", isHovering: isHovering) {
                print("Button 1 (Command) tapped")
            }
            
            // Button 2 (Center): CPU
            CrustButton(icon: "cpu", isHovering: isHovering) {
                print("Button 2 (CPU) tapped")
            }
            
            // Button 3 (Right): Flowchart
            CrustButton(icon: "flowchart", isHovering: isHovering) {
                print("Button 3 (Flowchart) tapped")
            }
        }
        .background(Color.clear)
        .padding(.bottom, 20) // Give it some padding from the bottom of the droplet
    }
}

struct CrustButton: View {
    let icon: String
    let isHovering: Bool
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
        .scaleEffect(isHovering ? 1.0 : 0.0)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovering)
    }
}
