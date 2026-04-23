import SwiftUI
import AppKit

struct RadialMenuView: View {
    @ObservedObject private var state = ZenithState.shared
    @State private var hoveredItemId: UUID?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background overlay (optional, for focus)
            if state.radialMenuIsOpen {
                Color.black
                    .opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }
            
            // Center notch/trigger point
            ZStack {
                Circle()
                    .fill(state.notchColor.color)
                    .opacity(state.notchOpacity)
                    .frame(width: 30, height: 30)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(state.radialMenuIsOpen ? 180 : 0))
            }
            .frame(width: 40, height: 40)
            
            // Radial menu items
            if state.radialMenuIsOpen {
                ForEach(Array(state.radialMenuItems.enumerated()), id: \.element.id) { index, item in
                    RadialMenuItemView(
                        item: item,
                        index: index,
                        totalItems: state.radialMenuItems.count,
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
        // Execute based on action type
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
        
        // Close menu after action
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
        // Open Spotlight or similar search
        NSApplication.shared.keyWindow?.makeKey()
        // Could integrate with system search or custom search
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
        .help(item.title) // Tooltip
    }
    
    private func calculateAngle(index: Int, totalItems: Int) -> Double {
        let angleStep = (2 * Double.pi) / Double(totalItems)
        let startAngle = -Double.pi / 2 // Start at top
        return startAngle + Double(index) * angleStep
    }
}

// MARK: - Radial Menu Coordinator

class RadialMenuCoordinator: NSObject {
    private var clickDetector: Any?
    private var hoverDetector: Timer?
    
    func setup(notchView: NSView) {
        let state = ZenithState.shared
        
        switch state.radialMenuMode {
        case .click:
            setupClickDetection(notchView: notchView)
        case .hover:
            setupHoverDetection(notchView: notchView)
        case .longPress:
            setupLongPressDetection(notchView: notchView)
        }
    }
    
    private func setupClickDetection(notchView: NSView) {
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        notchView.addGestureRecognizer(gesture)
    }
    
    private func setupHoverDetection(notchView: NSView) {
        let trackingArea = NSTrackingArea(
            rect: notchView.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        notchView.addTrackingArea(trackingArea)
    }
    
    private func setupLongPressDetection(notchView: NSView) {
        let gesture = NSPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesture.minimumPressDuration = 0.5
        notchView.addGestureRecognizer(gesture)
    }
    
    @objc private func handleClick() {
        ZenithState.shared.radialMenuIsOpen.toggle()
    }
    
    @objc private func handleLongPress(_ gesture: NSPressGestureRecognizer) {
        if gesture.state == .began {
            ZenithState.shared.radialMenuIsOpen = true
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        ZenithState.shared.radialMenuIsOpen = true
    }
    
    override func mouseExited(with event: NSEvent) {
        hoverDetector?.invalidate()
        hoverDetector = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            ZenithState.shared.radialMenuIsOpen = false
        }
    }
}
