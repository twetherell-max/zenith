import SwiftUI
import AppKit

// MARK: - RadialMenuView

struct RadialMenuView: View {
    @ObservedObject private var state = ZenithState.shared

    var body: some View {
        ZStack {
            if state.radialMenuIsOpen {
                // Invisible tap-outside-to-close layer
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        closeMenu()
                    }

                // Radial items
                ForEach(Array(enabledItems.enumerated()), id: \.element.id) { index, item in
                    RadialMenuItemView(
                        item: item,
                        itemSize: state.radialMenuItemSize,
                        showLabel: state.radialMenuShowLabels,
                        offset: itemOffset(for: index, total: enabledItems.count, radius: state.radialMenuRadius)
                    ) {
                        executeAction(for: item)
                        closeMenu()
                    }
                    .transition(itemTransition)
                }
            }
        }
        .animation(menuAnimation, value: state.radialMenuIsOpen)
    }

    // MARK: - Helpers

    private var enabledItems: [RadialMenuItem] {
        state.radialMenuItems.filter { $0.isEnabled }
    }

    private func itemOffset(for index: Int, total: Int, radius: Double) -> CGSize {
        guard total > 0 else { return .zero }
        let angle = (2 * Double.pi / Double(total)) * Double(index) - (Double.pi / 2)
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
    }

    private var menuAnimation: Animation {
        switch state.radialMenuAnimationStyle {
        case .spring:
            return .spring(response: 0.35, dampingFraction: 0.65)
        case .easeOut:
            return .easeOut(duration: 0.25)
        case .bounce:
            return .interpolatingSpring(stiffness: 300, damping: 12)
        }
    }

    private var itemTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.1).combined(with: .opacity),
            removal: .scale(scale: 0.1).combined(with: .opacity)
        )
    }

    // MARK: - Menu control

    func closeMenu() {
        state.radialMenuIsOpen = false
    }

    // MARK: - Action execution

    private func executeAction(for item: RadialMenuItem) {
        switch item.actionType {
        case .app:
            if !item.actionValue.isEmpty,
               let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: item.actionValue) {
                NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
            }

        case .folder:
            let path = item.actionValue.isEmpty ? NSHomeDirectory() : item.actionValue
            NSWorkspace.shared.open(URL(fileURLWithPath: path))

        case .url:
            if !item.actionValue.isEmpty, let url = URL(string: item.actionValue) {
                NSWorkspace.shared.open(url)
            }

        case .script:
            if !item.actionValue.isEmpty {
                state.runAppleScript(item.actionValue)
            }

        case .music:
            state.executeMusicAction(item.actionValue.isEmpty ? "playPause" : item.actionValue)

        case .settings:
            AppDelegate.shared.openSettings()

        case .search:
            let query = item.actionValue.isEmpty ? "" : item.actionValue
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
                NSWorkspace.shared.open(url)
            }

        case .clipboard:
            state.handleClipboard()
        }
    }
}

// MARK: - RadialMenuItemView

struct RadialMenuItemView: View {
    let item: RadialMenuItem
    let itemSize: Double
    let showLabel: Bool
    let offset: CGSize
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(itemBackgroundColor)
                    .frame(width: itemSize, height: itemSize)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .scaleEffect(isHovered ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovered)

                Text(item.icon)
                    .font(.system(size: itemSize * 0.45))
            }

            if showLabel {
                Text(item.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2)
                    .lineLimit(1)
            }
        }
        .offset(offset)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
        .contentShape(Circle().size(CGSize(width: itemSize + 16, height: itemSize + 16)))
    }

    private var itemBackgroundColor: Color {
        let hex = item.color.trimmingCharacters(in: .init(charactersIn: "#"))
        guard hex.count == 6,
              let rgb = UInt32(hex, radix: 16) else {
            return isHovered ? Color.white.opacity(0.3) : Color.white.opacity(0.2)
        }
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        return Color(red: r, green: g, blue: b).opacity(isHovered ? 0.9 : 0.75)
    }
}
