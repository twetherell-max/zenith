import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .top) { // ALIGN TO TOP
            HStack(spacing: 40) { // RIGID SPACING
                // Button 1 (Left)
                CrustButton(id: 1, label: "!!!", icon: "command", isHovering: isHovering, offset: CGSize(width: -70, height: 30)) {
                    print("Button 1 (Command) tapped")
                }
                
                // Button 2 (Center)
                CrustButton(id: 2, label: "!!!", icon: "cpu", isHovering: isHovering, offset: CGSize(width: 0, height: 60)) {
                    print("Button 2 (CPU) tapped")
                }
                
                // Button 3 (Right)
                CrustButton(id: 3, label: "!!!", icon: "flowchart", isHovering: isHovering, offset: CGSize(width: 70, height: 30)) {
                    print("Button 3 (Flowchart) tapped")
                }
            }
            .frame(width: 400, height: 100) // RIGID CONTAINER SIZE
            .background(Color.blue) // CONFIRM LOCATION
        }
        .frame(width: 800, height: 400)
    }
}

struct CrustButton: View {
    let id: Int
    let label: String
    let icon: String
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: 60, height: 60) // FIXED BUTTON SIZE
                    .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 5)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
                VStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
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
