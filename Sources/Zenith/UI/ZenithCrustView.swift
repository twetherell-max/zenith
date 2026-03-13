import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .center) { // CENTER EVERYTHING IN THE 800x400
            // DEBUG BACKGROUND
            Color.yellow.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 80) { // VISIBLE TEST SPACING
                // Button 1 (Left)
                CrustButton(id: 1, label: "BTN 1", icon: "command", isHovering: isHovering, color: .red) {
                    print("Button 1 (Command) tapped")
                }
                .zIndex(999)
                
                // Button 2 (Center)
                CrustButton(id: 2, label: "BTN 2", icon: "cpu", isHovering: isHovering, color: .green) {
                    print("Button 2 (CPU) tapped")
                }
                .zIndex(999)
                
                // Button 3 (Right)
                CrustButton(id: 3, label: "BTN 3", icon: "flowchart", isHovering: isHovering, color: .blue) {
                    print("Button 3 (Flowchart) tapped")
                }
                .zIndex(999)
            }
        }
        .frame(width: 800, height: 400)
    }
}

struct CrustButton: View {
    let id: Int
    let label: String
    let icon: String
    let isHovering: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        let _ = print(">>> CRUST: Rendering Button \(id) at \(Date())")
        
        Button(action: action) {
            ZStack {
                Rectangle() // SOLID COLOR BLOCK
                    .fill(color)
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .scaleEffect(isHovering ? 1.0 : 0.01)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovering)
    }
}
