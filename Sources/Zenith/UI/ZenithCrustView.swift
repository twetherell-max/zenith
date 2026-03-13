import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        HStack(spacing: 50) { // VISIBLE TEST SPACING
            // Button 1 (Left)
            CrustButton(id: 1, icon: "command", isHovering: isHovering, color: .red) {
                print("Button 1 (Command) tapped")
            }
            .zIndex(100)
            
            // Button 2 (Center)
            CrustButton(id: 2, icon: "cpu", isHovering: isHovering, color: .green) {
                print("Button 2 (CPU) tapped")
            }
            .zIndex(100)
            
            // Button 3 (Right)
            CrustButton(id: 3, icon: "flowchart", isHovering: isHovering, color: .blue) {
                print("Button 3 (Flowchart) tapped")
            }
            .zIndex(100)
        }
        .offset(y: 200) // EXTREME OFF-NOTCH OFFSET
    }
}

struct CrustButton: View {
    let id: Int
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
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .scaleEffect(isHovering ? 1.0 : 0.01)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovering)
    }
}
