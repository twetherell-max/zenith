import SwiftUI
import AppKit

struct MinimalNotchView: View {
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
        ZStack {
            if state.appMode == .minimal {
                // MINIMAL MODE: Only notch overlay
                VStack {
                    notchShape()
                    Spacer()
                }
            } else {
                // PRODUCTIVITY MODE: Keep existing views
                RadialDockView()
            }
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func notchShape() -> some View {
        if state.notchOverlayEnabled {
            HStack(spacing: 0) {
                Spacer()
                    .frame(maxWidth: .infinity)
                
                // The notch shape
                UnevenRoundedRectangle(
                    topLeadingRadius: state.notchCornerRadius,
                    topTrailingRadius: state.notchCornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0
                )
                .fill(state.notchColor.color)
                .opacity(state.notchOpacity)
                .frame(width: state.notchWidth, height: state.notchHeight)
                
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: state.notchHeight + 5)
            .padding(.top, 8)
        }
    }
}
