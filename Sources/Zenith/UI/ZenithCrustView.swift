import SwiftUI

struct ZenithCrustView: View {
    let isHovering: Bool
    
    var body: some View {
        let _ = print(">>> BODY DRAWN: I am rendering squares")
        
        ZStack {
            // DEBUG BACKGROUND
            Color.yellow.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
            }
            .frame(width: 400, height: 100)
        }
        .frame(width: 800, height: 400)
    }
}
