import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                HStack(spacing: 60) { // REFINED SPACING
                    // Button 1 (Left)
                    CrustButton(id: 1, label: "1", isHovering: isHovering, offset: CGSize(width: -80, height: 20)) {
                        print("Button 1 (Left) tapped")
                    }
                    
                    // Button 2 (Center)
                    CrustButton(id: 2, label: "2", isHovering: isHovering, offset: CGSize(width: 0, height: 40)) {
                        print("Button 2 (Center) tapped")
                    }
                    
                    // Button 3 (Right)
                    CrustButton(id: 3, label: "3", isHovering: isHovering, offset: CGSize(width: 80, height: 20)) {
                        print("Button 3 (Right) tapped")
                    }
                }
            }
            .frame(width: 400, height: 200)
            .padding(.top, 50)
        }
        .frame(width: 800, height: 400)
    }
}

struct CrustButton: View {
    let id: Int
    let label: String
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black) // NO TRANSPARENCY
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                
                Text(label)
                    .font(.system(size: 24, weight: .bold))
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
