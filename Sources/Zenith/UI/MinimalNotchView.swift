import SwiftUI
import AppKit

struct MinimalNotchView: View {
    @ObservedObject private var state = ZenithState.shared
    @State private var isHovering = false
    @State private var longPressTimer: Timer?

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

            // Radial menu rendered centered over the notch position
            if state.radialMenuEnabled && state.appMode == .minimal {
                RadialMenuView()
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

                ZStack {
                    // The notch shape
                    UnevenRoundedRectangle(
                        topLeadingRadius: state.notchCornerRadius,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: state.notchCornerRadius
                    )
                    .fill(Color(state.notchColor.color))
                    .opacity(state.notchOpacity)
                    .frame(width: state.notchWidth, height: state.notchHeight)

                    // Chevron indicator when radial menu is enabled
                    if state.radialMenuEnabled {
                        HStack {
                            Spacer()
                            Image(systemName: state.radialMenuIsOpen ? "chevron.up" : "chevron.down")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.trailing, 6)
                                .padding(.bottom, 4)
                                .frame(height: state.notchHeight)
                        }
                        .frame(width: state.notchWidth)
                    }
                }
                .frame(width: state.notchWidth, height: state.notchHeight)
                .contentShape(Rectangle())
                .gesture(notchGesture)
                .onHover { hovering in
                    isHovering = hovering
                    if state.radialMenuEnabled && state.radialMenuMode == .hover {
                        state.radialMenuIsOpen = hovering
                    }
                }

                Spacer()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: state.notchHeight + 5)
            .padding(.top, 8)
        }
    }

    private var notchGesture: some Gesture {
        if state.radialMenuEnabled && state.radialMenuMode == .longPress {
            return AnyGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        state.radialMenuIsOpen.toggle()
                    }
            )
        } else if state.radialMenuEnabled && state.radialMenuMode == .click {
            return AnyGesture(
                TapGesture()
                    .onEnded {
                        state.radialMenuIsOpen.toggle()
                    }
            )
        } else {
            return AnyGesture(TapGesture().onEnded { })
        }
    }
}

