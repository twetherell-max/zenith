import SwiftUI
import AppKit

struct RadialMenuView: View {
    @ObservedObject private var state = ZenithState.shared
    @State private var hoveredItemId: UUID?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Subtle background overlay
            if state.radialMenuIsOpen {
                Color.black
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }
            
            // Center notch indicator
            ZStack {
                Circle()
                    .fill(state.notchColor.color)
                    .opacity(state.notchOpacity)
                
                Image(systemName: "chevron.up")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(state.radialMenuIsOpen ? 0 : 180))
            }
            .frame(width: 35, height: 35)
            .zIndex(10)
            
            // Radial menu items
            if state.radialMenuIsOpen {
                ForEach(Array(state.radialMenuItems.enumerated()), id: \.element.id) { index, item in
                    if item.isEnabled {
                        RadialMenuItemView(
                            item: item,
                            index: index,
                            totalItems: state.radialMenuItems.filter { $0.isEnabled }.count,
                            radius: state.radialMenuRadius,
                            itemSize: state.radialMenuItemSize,
                            isHovered: hoveredItemId == item.id,
                            isAnimating: isAnimating
                        )
                        .onHover { isHovered in
                            hoveredItemId = isHovered ? item.id : nil
                            if isHovered {
                                NSFeedbackHelper().lightTap()
                            }
                        }
                        .onTapGesture {
                            executeMenuAction(item)
                        }
                    }
                }
            }
        }
        .frame(width: state.notchWidth, height: state.notchHeight + 20)
        .onAppear {
            if state.radialMenuIsOpen {
                animateMenuOpen()
            }
        }
        .onChange(of: state.radialMenuIsOpen) { newValue in
            if newValue {
                animateMenuOpen()
            } else {
                animateMenuClosed()
            }
        }
    }
    
    private func animateMenuOpen() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isAnimating = true
        }
    }
    
    private func animateMenuClosed() {
        withAnimation(.easeOut(duration: 0.2)) {
            isAnimating = false
        }
    }
    
    private func closeMenu() {
        state.radialMenuIsOpen = false
    }
    
    private func executeMenuAction(_ item: RadialMenuItem) {
        switch item.actionType {
        case .app:
            if !item.actionValue.isEmpty {
                openApplication(bundleId: item.actionValue)
            }
        case .folder:
            if !item.actionValue.isEmpty {
                openFolder(path: item.actionValue)
            }
        case .url:
            if !item.actionValue.isEmpty, let url = URL(string: item.actionValue) {
                NSWorkspace.shared.open(url)
            }
        case .script:
            if !item.actionValue.isEmpty {
                runAppleScript(item.actionValue)
            }
        case .music:
            executeMusicAction(item.actionValue)
        case .settings:
            AppDelegate.shared.openSettings()
        case .search:
            openSearchDialog(query: item.actionValue)
        case .clipboard:
            handleClipboard()
        case .custom:
            break
        }
        
        closeMenu()
    }
    
    private func openApplication(bundleId: String) {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
        }
    }
    
    private func openFolder(path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
    
    private func runAppleScript(_ script: String) {
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
    
    private func executeMusicAction(_ action: String) {
        let script: String
        switch action {
        case "playPause": script = "tell application \"Music\" to playpause"
        case "next": script = "tell application \"Music\" to next track"
        case "previous": script = "tell application \"Music\" to previous track"
        default: script = "tell application \"Music\" to playpause"
        }
        runAppleScript(script)
    }
    
    private func openSearchDialog(query: String) {
        NSApplication.shared.keyWindow?.makeKey()
    }
    
    private func handleClipboard() {
        let pasteboard = NSPasteboard.general
        if let clipboardString = pasteboard.string(forType: .string) {
            print("Clipboard: \(clipboardString)")
        }
    }
}

// MARK: - Individual Radial Menu Item

struct RadialMenuItemView: View {
    let item: RadialMenuItem
    let index: Int
    let totalItems: Int
    let radius: Double
    let itemSize: Double
    let isHovered: Bool
    let isAnimating: Bool
    
    var body: some View {
        let angle = calculateAngle(index: index, totalItems: totalItems)
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        
        ZStack {
            // Background circle
            Circle()
                .fill(item.color == .auto ? Color.orange : Color(item.color.nsColor))
                .opacity(isHovered ? 0.9 : 0.7)
            
            // Icon
            Image(systemName: item.icon)
                .font(.system(size: itemSize * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: itemSize, height: itemSize)
        .scaleEffect(isHovered ? 1.2 : 1.0)
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(
            x: isAnimating ? x : 0,
            y: isAnimating ? y : 0
        )
        .help(item.title)
    }
    
    private func calculateAngle(index: Int, totalItems: Int) -> Double {
        let angleStep = (2 * Double.pi) / Double(totalItems)
        let startAngle = -Double.pi / 2
        return startAngle + Double(index) * angleStep
    }
}
