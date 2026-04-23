import SwiftUI
import AppKit

struct MinimalNotchView: View {
    @ObservedObject private var state = ZenithState.shared
    @State private var isNotchHovered = false
    
    var body: some View {
        ZStack {
            if state.appMode == .minimal {
                if state.radialMenuEnabled && state.radialMenuIsOpen {
                    // Show radial menu
                    RadialMenuView()
                } else {
                    // Show only notch
                    VStack {
                        notchShape()
                        Spacer()
                    }
                }
            } else {
                // PRODUCTIVITY MODE: Keep existing views
                RadialDockView()
            }
        }
        .background(Color.clear)
        .onHover { isHovered in
            isNotchHovered = isHovered
            if state.radialMenuEnabled && state.radialMenuMode == .hover {
                if isHovered {
                    state.radialMenuIsOpen = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if !isNotchHovered {
                            state.radialMenuIsOpen = false
                        }
                    }
                }
            }
        }
        .onTapGesture {
            if state.radialMenuEnabled && state.radialMenuMode == .click {
                state.radialMenuIsOpen.toggle()
            }
        }
    }
    
    @ViewBuilder
    private func notchShape() -> some View {
        if state.notchOverlayEnabled {
            HStack(spacing: 0) {
                Spacer()
                    .frame(maxWidth: .infinity)
                
                // The notch shape with interactive areas
                ZStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: state.notchCornerRadius,
                        topTrailingRadius: state.notchCornerRadius,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0
                    )
                    .fill(state.notchColor.color)
                    .opacity(state.notchOpacity)
                    
                    // Dropdown indicator
                    if state.radialMenuEnabled {
                        VStack(spacing: 2) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(0.6)
                        }
                    }
                }
                .frame(width: state.notchWidth, height: state.notchHeight)
                
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: state.notchHeight + 5)
            .padding(.top, 8)
        }
    }
}
