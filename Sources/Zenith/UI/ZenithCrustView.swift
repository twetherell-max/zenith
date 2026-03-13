import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack {
            // Button 1 (Left): Command - Red border
            CrustButton(icon: "command", isHovering: isHovering, offset: CGSize(width: -80, height: 50), color: .red) {
                print("Button 1 (Command) tapped")
            }
            
            // Button 2 (Center): CPU - Green border
            CrustButton(icon: "cpu", isHovering: isHovering, offset: CGSize(width: 0, height: 90), color: .green) {
                print("Button 2 (CPU) tapped")
            }
            
            // Button 3 (Right): Flowchart - Blue border
            CrustButton(icon: "flowchart", isHovering: isHovering, offset: CGSize(width: 80, height: 50), color: .blue) {
                print("Button 3 (Flowchart) tapped")
            }
        }
        .background(Color.clear)
    }
}

struct CrustButton: View {
    let icon: String
    let isHovering: Bool
    let offset: CGSize
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.8), lineWidth: 2) // Debug border
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Standard hit-area expansion
        .offset(isHovering ? offset : .zero)
        .scaleEffect(isHovering ? 1.0 : 0.01) // 0.01 to keep hit area sometimes? No, 0 is fine if offset is used correctly. 
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovering)
    }
}
