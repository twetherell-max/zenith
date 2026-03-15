import SwiftUI

struct ZenithDropletView: View {
    @Binding var isPulsing: Bool
    
    @ObservedObject var state = ZenithState.shared
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .top) { 
            // Radial Menu
            ZenithCrustView(isHovering: state.isExpanded || state.isSettingsOpen)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // BRAIN ID ANCHOR
            Text("BRAIN ID: \(state.debugID)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 2)
        }
        .contentShape(Rectangle()) 
        .id("zenith-main-view") 
        .onChange(of: state.arcSpread) { _, _ in }
        .onChange(of: state.dropDepth) { _, _ in }
        .onChange(of: state.isSettingsOpen) { _, newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if newValue { state.isExpanded = true }
            }
        }
        .onHover { hovering in
            if !state.isSettingsOpen {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    state.isExpanded = hovering
                }
            }
        }
        .frame(width: 800, height: 200)
        .contentShape(Rectangle()) 
        .background(Color.black.opacity(0.001)) 
        .onReceive(timer) { _ in state.objectWillChange.send() }
    }
}
