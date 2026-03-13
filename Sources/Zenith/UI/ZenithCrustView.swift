import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .top) { // ALIGN TO TOP
            VStack {
                HStack(spacing: 60) { // REFINED SPACING
                    // Button 1 (Left)
                    CrustButton(id: 1, label: "1", color: .red, isHovering: isHovering, offset: CGSize(width: -80, height: 20)) {
                        print("Button 1 (Left) tapped")
                    }
                    
                    // Button 2 (Center)
                    CrustButton(id: 2, label: "2", color: .green, isHovering: isHovering, offset: CGSize(width: 0, height: 40)) {
                        print("Button 2 (Center) tapped")
                    }
                    
                    // Button 3 (Right)
                    CrustButton(id: 3, label: "3", color: .blue, isHovering: isHovering, offset: CGSize(width: 80, height: 20)) {
                        print("Button 3 (Right) tapped")
                    }
                }
                .frame(width: 400, height: 100)
                .zIndex(5) // FORCE FOREGROUND
                
                Text("VISIBLE NOW")
                    .foregroundColor(.white)
            }
            .frame(width: 400, height: 250) // EXPANDED HEIGHT
            .padding(.top, 50)
        }
        .frame(width: 800, height: 400)
    }
}

struct CrustButton: View {
    let id: Int
    let label: String
    let color: Color
    let isHovering: Bool
    let offset: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color) // SLEDGEHAMMER COLOR
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4)) // THICK STROKE
                
                Text(label)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 60, height: 60) // EXPLICIT BUTTON FRAME
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
        // SLEDGEHAMMER: REMOVED ALL OFFSETS AND OPACITY
    }
}
