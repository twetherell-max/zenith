import SwiftUI

struct ZenithDropletView: View {
    @Binding var isHovering: Bool
    @Binding var isPulsing: Bool
    
    var body: some View {
        Text("CONTENT CONNECTED")
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.white)
            .frame(width: 800, height: 400)
            .background(Color.green)
    }
}
