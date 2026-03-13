import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack {
            // Button 1 (Left): 135°
            CrustButton(icon: "command", angle: 135, isHovering: isHovering) {
                print("Button 1 (Command) tapped")
            }
            
            // Button 2 (Center): 180°
            CrustButton(icon: "cpu", angle: 180, isHovering: isHovering) {
                print("Button 2 (CPU) tapped")
            }
            
            // Button 3 (Right): 225°
            CrustButton(icon: "flowchart", angle: 225, isHovering: isHovering) {
                print("Button 3 (Flowchart) tapped")
            }
        }
    }
}

struct CrustButton: View {
    let icon: String
    let angle: Double
    let isHovering: Bool
    let action: () -> Void
    
    // Distance to fly out from center
    let radius: CGFloat = 65
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovering ? 1.0 : 0.0)
        .offset(
            x: isHovering ? radius * cos(angle * .pi / 180) : 0,
            y: isHovering ? radius * sin(angle * .pi / 180) : 0
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isHovering)
    }
}
