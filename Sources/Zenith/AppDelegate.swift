import AppKit
import SwiftUI
import WebKit
import Combine

extension Notification.Name {
    static let zenithPulseRequested = Notification.Name("zenithPulseRequested")
}

class RadialDockContainerView: NSView {
    weak var webView: WKWebView?
    var mouseTimer: Timer?
    private var isExpanded = false
    private var lastHapticTime: Date = .distantPast
    var isSettingsOpen = false
    
    override var acceptsFirstResponder: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Pass all events to the webView - it handles click detection via JavaScript
        return webView
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        expandDock()
    }
    
    override func mouseExited(with event: NSEvent) {
        // Keep dock expanded - don't collapse on mouse exit
    }
    
    private func expandDock() {
        if !isExpanded {
            let state = ZenithState.shared
            if state.hapticFeedback {
                triggerHaptic()
            }
            isExpanded = true
            webView?.evaluateJavaScript("setExpanded(true)") { _, _ in }
        }
    }
    
    private func collapseDock() {
        // Called manually when needed
        if isExpanded {
            isExpanded = false
            webView?.evaluateJavaScript("setExpanded(false)") { _, _ in }
        }
    }
    
    private func triggerHaptic() {
        let now = Date()
        guard now.timeIntervalSince(lastHapticTime) > 0.3 else { return }
        lastHapticTime = now
        
        let generator = NSFeedbackHelper()
        generator.lightTap()
    }
    
    func startMouseTracking() {
        var wasInHoverArea = false
        mouseTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let mouseLoc = NSEvent.mouseLocation
            guard let window = self.window else { return }
            let windowLoc = window.convertPoint(fromScreen: mouseLoc)
            let localLoc = self.convert(windowLoc, from: nil)
            
            let state = ZenithState.shared
            let hoverWidth = CGFloat(state.notchWidth)
            let hoverHeight: CGFloat = 220
            
            let hoverArea = NSRect(
                x: self.bounds.width/2 - hoverWidth/2 - 50,
                y: self.bounds.height - hoverHeight,
                width: hoverWidth + 100,
                height: hoverHeight
            )
            
            let isInHoverArea = hoverArea.contains(localLoc)
            
            if isInHoverArea && !wasInHoverArea {
                wasInHoverArea = true
                self.expandDock()
            } else if !isInHoverArea && wasInHoverArea {
                wasInHoverArea = false
                self.collapseDock()
            }
        }
    }
}

enum SettingsWindowStyle {
    case centered
    case sidePanel
}

class SilhouetteSettingsWindow: NSPanel {
    var onClose: (() -> Void)?
    let style: SettingsWindowStyle
    private let windowWidth: CGFloat = 400
    private let windowHeight: CGFloat = 700
    
    init(style: SettingsWindowStyle = .centered) {
        self.style = style
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Settings"
        self.isOpaque = true
        self.backgroundColor = NSColor.windowBackgroundColor
        self.level = .modalPanel
        self.hasShadow = true
        self.isReleasedWhenClosed = false
        self.isRestorable = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let settingsView = SettingsPanelView(onClose: { [weak self] in
            self?.closePanel()
        })
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        
        self.contentView = hostingView
    }
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    func positionOnScreen() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        switch style {
        case .centered:
            let windowX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
            let windowY = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
            self.setFrameOrigin(NSPoint(x: windowX, y: windowY))
            
        case .sidePanel:
            let windowX = screenFrame.origin.x - windowWidth
            let windowY = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
            self.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        }
    }
    
    func show(animated: Bool = true) {
        positionOnScreen()
        
        if style == .sidePanel && animated {
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let targetX = screenFrame.origin.x + 20
                
                var startFrame = self.frame
                startFrame.origin.x = screenFrame.origin.x - windowWidth
                self.setFrame(startFrame, display: false)
                
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.3
                    context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    var targetFrame = self.frame
                    targetFrame.origin.x = targetX
                    self.animator().setFrame(targetFrame, display: true)
                }
            }
        }
        
        self.makeKeyAndOrderFront(nil)
    }
    
    func closePanel() {
        if style == .sidePanel {
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.25
                    context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    var exitFrame = self.frame
                    exitFrame.origin.x = screenFrame.origin.x - self.windowWidth
                    self.animator().setFrame(exitFrame, display: true)
                } completionHandler: {
                    self.close()
                    self.onClose?()
                }
            }
        } else {
            self.close()
            onClose?()
        }
    }
}

// Settings panel view with all options
struct SettingsPanelView: View {
    let onClose: () -> Void
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and close button
            HStack {
                Text("ZENITH")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Scrollable content
            ScrollView([.vertical], showsIndicators: true) {
                VStack(alignment: .leading, spacing: 20) {
                    notchSection()
                    barSection()
                    appearanceSection()
                    customizationSection()
                    dockButtonsSection()
                    behaviorSection()
                    aboutSection()
                }
                .padding(20)
            }
        }
        .frame(width: 400, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    @ViewBuilder
    private func barSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BAR").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Height")
                    Spacer()
                    Text("\(Int(state.barHeight))px")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.barHeight, in: 4...30, step: 1)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Opacity")
                    Spacer()
                    Text("\(Int(state.barOpacity * 100))%")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.barOpacity, in: 0.1...1, step: 0.05)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func appearanceSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPEARANCE").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Accent Color")
                    .font(.subheadline)
                Picker("Accent Color", selection: $state.accentColor) {
                    ForEach(AccentColor.allCases, id: \.self) { color in
                        Text(color.displayName).tag(color)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Contrast")
                    Spacer()
                    Text("\(Int(state.contrastLevel * 100))%")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.contrastLevel, in: 0...1, step: 0.05)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Dock Opacity")
                    Spacer()
                    Text("\(Int(state.dockOpacity * 100))%")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.dockOpacity, in: 0.2...1, step: 0.05)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func customizationSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SIZE & SPACING").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Arc Spread")
                    Spacer()
                    Text("\(Int(state.arcSpread))")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.arcSpread, in: 20...150, step: 1)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Icon Size")
                    Spacer()
                    Text("\(Int(state.iconSize))")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.iconSize, in: 10...30, step: 1)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Notch Width")
                    Spacer()
                    Text("\(Int(state.notchWidth))")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.notchWidth, in: 50...250, step: 10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Border Width")
                    Spacer()
                    Text("\(Int(state.borderWidth))px")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                Slider(value: $state.borderWidth, in: 0...3, step: 0.5)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func dockButtonsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DOCK BUTTONS").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                Spacer()
                Button("Reset") {
                    state.dockButtons = DockButton.defaultButtons
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Style")
                    .font(.subheadline)
                Picker("Style", selection: $state.dockStyle) {
                    ForEach(DockButton.DockStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if state.dockStyle == .minimal {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Outline Color")
                        .font(.subheadline)
                    Picker("Outline", selection: $state.useWhiteOutline) {
                        Text("White").tag(true)
                        Text("Accent").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func behaviorSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BEHAVIOR").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            Toggle("Haptic Feedback", isOn: $state.hapticFeedback)
                .font(.subheadline)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func notchSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MODE").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            Picker("App Mode", selection: $state.appMode) {
                Text("Minimal (Notch Only)").tag(ZenithState.AppMode.minimal)
                Text("Productivity (Full Suite)").tag(ZenithState.AppMode.productivity)
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
        
        if state.appMode == .minimal {
            VStack(alignment: .leading, spacing: 12) {
                Text("NOTCH APPEARANCE").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                
                // Color picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Color").font(.subheadline)
                    Picker("Notch Color", selection: $state.notchColor) {
                        ForEach(NotchColor.allCases, id: \.self) { color in
                            Text(color.rawValue.capitalized).tag(color)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Height
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Height")
                        Spacer()
                        Text("\(Int(state.notchHeight))px")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $state.notchHeight, in: 20...50, step: 1)
                }
                
                // Width
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Width")
                        Spacer()
                        Text("\(Int(state.notchWidth))px")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $state.notchWidth, in: 100...300, step: 5)
                }
                
                // Corner radius
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Corner Radius")
                        Spacer()
                        Text("\(Int(state.notchCornerRadius))px")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $state.notchCornerRadius, in: 0...30, step: 1)
                }
                
                // Opacity
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Opacity")
                        Spacer()
                        Text("\(Int(state.notchOpacity * 100))%")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $state.notchOpacity, in: 0.3...1.0, step: 0.05)
                }
                
                // Multi-monitor
                VStack(alignment: .leading, spacing: 6) {
                    Text("Multi-Monitor").font(.subheadline)
                    Picker("Monitors", selection: $state.multiMonitorMode) {
                        Text("Primary Only").tag(ZenithState.MultiMonitorMode.primaryOnly)
                        Text("All Monitors").tag(ZenithState.MultiMonitorMode.allMonitors)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(10)
        }
    }
    
    @ViewBuilder
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ABOUT").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            
            HStack {
                Text("Version")
                    .font(.subheadline)
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(10)
    }
}

class NSFeedbackHelper {
    func lightTap() {
        let event = CGEvent(source: nil)
        event?.type = .flagsChanged
        event?.post(tap: .cghidEventTap)
    }
}

class RadialDockCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    var settingsCheckTimer: Timer?
    private var isWebViewReady = false
    private var pendingSettingsUpdate: String?
    private var pendingButtonsUpdate: String?
    private var settingsCancellable: AnyCancellable?
    
    override init() {
        super.init()
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
        setupReactiveSync()
    }
    
    private func setupReactiveSync() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.syncSettingsReactive()
        }
    }
    
    func syncSettingsReactive() {
        let state = ZenithState.shared
        let accentColors: [String: String] = [
            "white": "#FFFFFF",
            "blue": "#007AFF",
            "purple": "#AF52DE",
            "pink": "#FF2D55",
            "orange": "#FF9500",
            "green": "#34C759"
        ]
        let color = accentColors[state.accentColor.rawValue] ?? "#FFFFFF"
        
        let settingsJson = """
        {
            "buttonShape": "\(state.buttonShape.rawValue)",
            "accentColor": "\(color)",
            "iconSize": \(state.iconSize),
            "opacity": \(state.dockOpacity * 0.15),
            "contrast": \(state.contrastLevel * 0.3),
            "arcSpread": \(state.arcSpread),
            "dropDepth": \(state.dropDepth),
            "hoverLift": \(state.hoverLift),
            "borderWidth": \(state.borderWidth),
            "notchWidth": \(state.notchWidth),
            "dockStyle": "\(state.dockStyle.rawValue)"
        }
        """
        
        if isWebViewReady {
            webView?.evaluateJavaScript("updateSettings(\(settingsJson))") { _, error in
                if let error = error {
                    print("Settings sync error: \(error)")
                }
            }
            
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(state.dockButtons),
               let buttonsJson = String(data: data, encoding: .utf8) {
                webView?.evaluateJavaScript("updateButtons(\(buttonsJson))") { _, error in
                    if let error = error {
                        print("Buttons sync error: \(error)")
                    }
                }
            }
        } else {
            pendingSettingsUpdate = settingsJson
            if let data = try? JSONEncoder().encode(state.dockButtons),
               let buttonsJson = String(data: data, encoding: .utf8) {
                pendingButtonsUpdate = buttonsJson
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewReady = true
        
        if let settings = pendingSettingsUpdate {
            webView.evaluateJavaScript("updateSettings(\(settings))") { _, _ in }
            pendingSettingsUpdate = nil
        }
        if let buttons = pendingButtonsUpdate {
            webView.evaluateJavaScript("updateButtons(\(buttons))") { _, _ in }
            pendingButtonsUpdate = nil
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error)")
        isWebViewReady = false
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "radialDock",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }
        
        print(">>> Received message: \(type)")
        
        if type == "openSettings" {
            AppDelegate.shared?.openSettings()
        } else if type == "checkSettings" {
            DispatchQueue.main.async { [weak self] in
                let isOpen = NSApp.windows.contains { $0.title == "Zenith Settings" && $0.isVisible }
                self?.webView?.evaluateJavaScript("setPreviewMode(\(isOpen))") { _, _ in }
            }
        } else if type == "buttonClick" {
            if let actionType = body["actionType"] as? String,
               let actionValue = body["actionValue"] as? String {
                DispatchQueue.main.async {
                    self.handleButtonAction(type: actionType, value: actionValue)
                }
            }
        }
    }
    
    private func handleButtonAction(type: String, value: String) {
        switch type {
        case "settings":
            AppDelegate.shared.openSettings()
            
        case "app":
            if !value.isEmpty {
                openApplication(bundleId: value)
            }
            
        case "url":
            if !value.isEmpty, let url = URL(string: value) {
                NSWorkspace.shared.open(url)
            }
            
        case "folder":
            if !value.isEmpty {
                openFolder(path: value)
            }
            
        case "script":
            if !value.isEmpty {
                runAppleScript(value)
            }
            
        case "music":
            runMusicAction(value)
            
        case "clipboard":
            handleClipboard()
            
        default:
            break
        }
    }
    
    private func openApplication(bundleId: String) {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
        } else {
            print(">>> Could not find app with bundle ID: \(bundleId)")
        }
    }
    
    private func openFolder(path: String) {
        let folderURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.open(folderURL)
        } else {
            print(">>> Folder does not exist: \(path)")
        }
    }
    
    private func runAppleScript(_ script: String) {
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print(">>> AppleScript error: \(error)")
            }
        }
    }
    
    private func runMusicAction(_ action: String) {
        let script: String
        switch action {
        case "playPause":
            script = "tell application \"Music\" to playpause"
        case "next":
            script = "tell application \"Music\" to next track"
        case "previous":
            script = "tell application \"Music\" to previous track"
        case "volumeUp":
            script = "set volume output volume ((output volume of (get volume settings)) + 10)"
        case "volumeDown":
            script = "set volume output volume ((output volume of (get volume settings)) - 10)"
        case "mute":
            script = "set volume with output muted"
        default:
            script = "tell application \"Music\" to playpause"
        }
        runAppleScript(script)
    }
    
    private func handleClipboard() {
        let pasteboard = NSPasteboard.general
        if let clipboardString = pasteboard.string(forType: .string) {
            pasteboard.clearContents()
            pasteboard.setString(clipboardString, forType: .string)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NativeRadialDockDelegate {
    static var shared: AppDelegate!
    
    var statusItem: NSStatusItem?
    var zenithWindow: NSWindow?
    var settingsWindow: SilhouetteSettingsWindow?
    var quickNoteWindow: QuickNoteWindow?
    var musicPopupWindow: MusicPopupWindow?
    var dockCoordinator: RadialDockCoordinator?
    var dockView: NSView?
    private var dockContainerView: NSView?
    private var globalMouseMonitor: Any?
    private var hoverTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    func notchClicked() {
        // Toggle dock expansion
    }
    
    private func isMouseInNotchZone(_ location: NSPoint) -> Bool {
        guard let screen = NSScreen.main else { return false }
        let screenFrame = screen.frame
        
        let notchZone = NSRect(
            x: screenFrame.width / 2 - 75,
            y: screenFrame.height - 50,
            width: 150,
            height: 50
        )
        
        return notchZone.contains(location)
    }
    
    private func isMouseInZenithArea() -> Bool {
        guard let window = zenithWindow else { return false }
        let mouseLocation = NSEvent.mouseLocation
        let windowFrame = window.frame
        
        let windowRect = NSRect(
            x: windowFrame.origin.x,
            y: windowFrame.origin.y,
            width: windowFrame.width,
            height: windowFrame.height
        )
        
        return windowRect.contains(mouseLocation)
    }
    
    private func startGlobalMouseMonitoring() {
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            self?.checkMousePosition()
        }
    }
    
    private func checkMousePosition() {
        let mouseLocation = NSEvent.mouseLocation
        let isInNotchZone = isMouseInNotchZone(mouseLocation)
        let isInZenithArea = isMouseInZenithArea()
        
        if isInNotchZone || isInZenithArea {
            hoverTimer?.invalidate()
            showNotchFromGlobal()
        } else {
            hoverTimer?.invalidate()
            hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
                self?.hideNotchFromGlobal()
            }
        }
    }
    
    private func showNotchFromGlobal() {
        if let nativeDockView = dockView as? NativeRadialDockView {
            nativeDockView.showNotchFromExternal()
        } else if let listDockView = dockView as? ListDockView {
            listDockView.showFromExternal()
        }
    }
    
    private func hideNotchFromGlobal() {
        if let nativeDockView = dockView as? NativeRadialDockView {
            nativeDockView.hideNotchFromExternal()
        } else if let listDockView = dockView as? ListDockView {
            listDockView.hideFromExternal()
        }
    }
    
    func iconClicked(button: DockButton) {
        handleButtonAction(button)
    }
    
    private func handleButtonAction(_ button: DockButton) {
        switch button.actionType {
        case .settings:
            if settingsWindow == nil {
                openSettings()
            } else {
                closeSettings()
            }
        case .music:
            switch ZenithState.shared.musicDisplayMode {
            case .icon:
                if !button.actionValue.isEmpty {
                    ZenithState.shared.executeMusicAction(button.actionValue, service: button.musicService)
                }
            case .artwork:
                if !button.actionValue.isEmpty {
                    ZenithState.shared.executeMusicAction(button.actionValue, service: button.musicService)
                }
            case .popup:
                toggleMusicPopup()
            }
        case .note:
            openQuickNote()
        case .app:
            if !button.actionValue.isEmpty {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: button.actionValue) {
                    NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
                }
            }
        case .folder:
            if !button.actionValue.isEmpty {
                let url = URL(fileURLWithPath: button.actionValue)
                NSWorkspace.shared.open(url)
            }
        case .url:
            if let url = URL(string: button.actionValue) {
                NSWorkspace.shared.open(url)
            }
        case .script:
            if !button.actionValue.isEmpty {
                ZenithState.shared.runAppleScript(button.actionValue)
            }
        case .clipboard:
            ZenithState.shared.handleClipboard()
        case .icon:
            break
        }
    }
    
    func openSettings() {
        print(">>> openSettings called")
        
        if settingsWindow == nil {
            print(">>> Creating settings side panel")
            
            let window = SilhouetteSettingsWindow(style: .sidePanel)
            window.onClose = { [weak self] in
                self?.closeSettings()
            }
            settingsWindow = window
            
            // Show the notch when settings opens (preview mode)
            ZenithState.shared.isSettingsOpen = true
            
            // Slide in from right
            window.show(animated: true)
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    func closeSettings() {
        ZenithState.shared.isSettingsOpen = false
        
        if let window = settingsWindow {
            window.closePanel()
            settingsWindow = nil
        }
    }
    
    func openQuickNote() {
        if quickNoteWindow == nil {
            quickNoteWindow = QuickNoteWindow(
                onSave: { [weak self] text in
                    if !text.isEmpty {
                        TodoStore.shared.addNote(text)
                    }
                    self?.quickNoteWindow = nil
                },
                onCancel: { [weak self] in
                    self?.quickNoteWindow = nil
                }
            )
        }
        quickNoteWindow?.show()
    }
    
    func toggleMusicPopup() {
        if let existingWindow = musicPopupWindow {
            existingWindow.close()
            musicPopupWindow = nil
        } else {
            musicPopupWindow = MusicPopupWindow()
            musicPopupWindow?.show()
        }
    }
    
    func syncDockSettings() {
        let state = ZenithState.shared
        let accentColors: [String: String] = [
            "white": "#FFFFFF",
            "blue": "#007AFF",
            "purple": "#AF52DE",
            "pink": "#FF2D55",
            "orange": "#FF9500",
            "green": "#34C759"
        ]
        let color = accentColors[state.accentColor.rawValue] ?? "#FFFFFF"
        
        let settingsJson = """
        {
            "buttonShape": "\(state.buttonShape.rawValue)",
            "accentColor": "\(color)",
            "iconSize": \(state.iconSize),
            "opacity": \(state.dockOpacity * 0.15),
            "contrast": \(state.contrastLevel * 0.3),
            "arcSpread": \(state.arcSpread),
            "dropDepth": \(state.dropDepth),
            "hoverLift": \(state.hoverLift),
            "borderWidth": \(state.borderWidth),
            "notchWidth": \(state.notchWidth),
            "dockStyle": "\(state.dockStyle.rawValue)"
        }
        """
        
        dockCoordinator?.webView?.evaluateJavaScript("updateSettings(\(settingsJson))") { _, _ in }
        
        let buttonsJson = dockButtonsToJson()
        dockCoordinator?.webView?.evaluateJavaScript("updateButtons(\(buttonsJson))") { _, _ in }
    }
    
    private func dockButtonsToJson() -> String {
        let state = ZenithState.shared
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(state.dockButtons),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }
    
    // Explicit access to state for injection
    let state = ZenithState.shared
    
    private func createZIcon() -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size, flipped: false) { rect in
            let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: 1, dy: 1))
            NSColor.white.withAlphaComponent(0.3).setFill()
            circlePath.fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: NSColor.white
            ]
            let zString = "Z"
            let textSize = zString.size(withAttributes: attributes)
            let textRect = NSRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            zString.draw(in: textRect, withAttributes: attributes)
            return true
        }
        image.isTemplate = false
        return image
    }
 
    override init() {
        super.init()
        AppDelegate.shared = self
        print(">>> AppDelegate initialized")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // THE SHARED LINK - ABSOLUTE FIRST LINE
        AppDelegate.shared = self
        
        // Safety: ensure activation policy is correct
        NSApp.setActivationPolicy(.regular)
        
        // Kill ghosts
        NSApp.disableRelaunchOnLogin()
        
        // FORCE MENU BAR
        setupStatusItem()
        
        // Initialize notch window manager for minimal mode
        _ = NotchWindowManager.shared

        if self.zenithWindow == nil {
            print(">>> Creating Zenith Window...")
            
            let screen = NSScreen.main ?? NSScreen.screens[0]
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            
            print(">>> Screen frame: \(screenFrame)")
            print(">>> Visible frame: \(visibleFrame)")
            print(">>> Screen height: \(screenFrame.height)")
            
            // Use a fixed, simple window position
            let windowWidth: CGFloat = 400
            let windowHeight: CGFloat = 200
            
            // Position at bottom of screen (easier to see)
            let windowX: CGFloat = 100
            let windowY: CGFloat = 100

            let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)
            
            let window = NSWindow(
                contentRect: windowFrame,
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            // Simple colored window
            window.backgroundColor = NSColor.systemPink
            window.isOpaque = true
            window.title = "Zenith"
            window.level = .normal
            window.hasShadow = true
            
            window.titlebarAppearsTransparent = false
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
            
            print(">>> Window frame after creation: \(window.frame)")
            print(">>> Window origin: x=\(window.frame.origin.x), y=\(window.frame.origin.y)")
            print(">>> Window size: w=\(window.frame.width), h=\(window.frame.height)")
            
            // Create dock view based on layout setting
            let dockFrame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
            print(">>> dockFrame: \(dockFrame)")
            
            if ZenithState.shared.dockLayout == .radial {
                let nativeDockView = NativeRadialDockView(frame: dockFrame)
                nativeDockView.delegate = self
                nativeDockView.wantsLayer = true
                nativeDockView.layer?.backgroundColor = NSColor.cyan.cgColor
                dockView = nativeDockView
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    nativeDockView.updateLayout()
                    print(">>> Radial dock updateLayout called")
                }
            } else {
                let listDockView = ListDockView(frame: dockFrame)
                listDockView.delegate = self
                listDockView.wantsLayer = true
                listDockView.layer?.backgroundColor = NSColor.cyan.cgColor
                dockView = listDockView
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    listDockView.updateLayout()
                    print(">>> List dock updateLayout called")
                }
            }
            
            window.contentView = nil
            
            let container = NSView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
            container.wantsLayer = true
            container.layer?.backgroundColor = NSColor.systemPink.cgColor
            container.layer?.borderColor = NSColor.black.cgColor
            container.layer?.borderWidth = 10
            
            if let dockView = dockView {
                dockView.frame = container.bounds
                dockView.autoresizingMask = [.width, .height]
                container.addSubview(dockView)
            }
            
            window.contentView = container
            dockContainerView = container
            
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil as Any?)
            
            print(">>> Window frame final: \(window.frame)")
            print(">>> Window ordered front")
            
            self.zenithWindow = window
        }
        
        ShortcutManager.shared.startMonitoring { [weak self] type in
            switch type {
            case .toggle:
                self?.handleZenModeToggle()
            case .pulse:
                self?.handlePulseShortcut()
            }
        }
        
        // Start global mouse monitoring for notch/camera hover detection
        startGlobalMouseMonitoring()
        
        // Observe dock layout changes
        ZenithState.shared.$dockLayout
            .receive(on: RunLoop.main)
            .sink { [weak self] layout in
                print(">>> dockLayout changed to: \(layout)")
                self?.recreateDockView()
            }
            .store(in: &cancellables)
    }
    
    private func recreateDockView() {
        guard let window = zenithWindow else { 
            print(">>> recreateDockView: no window")
            return 
        }
        guard let container = dockContainerView ?? window.contentView else {
            print(">>> recreateDockView: no container")
            return
        }
        
        let currentLayout = ZenithState.shared.dockLayout
        print(">>> recreateDockView: layout = \(currentLayout)")
        
        let dockFrame = container.bounds
        
        dockView?.removeFromSuperview()
        
        if currentLayout == .radial {
            let nativeDockView = NativeRadialDockView(frame: dockFrame)
            nativeDockView.delegate = self
            nativeDockView.wantsLayer = true
            nativeDockView.layer?.backgroundColor = NSColor.cyan.cgColor
            dockView = nativeDockView
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                nativeDockView.updateLayout()
            }
        } else {
            let listDockView = ListDockView(frame: dockFrame)
            listDockView.delegate = self
            listDockView.wantsLayer = true
            listDockView.layer?.backgroundColor = NSColor.cyan.cgColor
            dockView = listDockView
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                listDockView.updateLayout()
            }
        }
        
        if let dockView = dockView {
            dockView.frame = container.bounds
            dockView.autoresizingMask = [.width, .height]
            container.addSubview(dockView)
        }
    }
    
    private func setupStatusItem() {
        let menu = NSMenu()
        
        // Toggle mode
        let toggleModeItem = NSMenuItem(title: "Switch to Minimal Mode", action: #selector(toggleAppMode), keyEquivalent: "m")
        toggleModeItem.target = self
        menu.addItem(toggleModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menu
        statusItem?.button?.image = createZIcon()
    }
    
    @objc private func toggleAppMode() {
        let state = ZenithState.shared
        state.appMode = state.appMode == .minimal ? .productivity : .minimal
        
        // Update menu title
        if let menu = statusItem?.menu, let item = menu.item(at: 0) {
            item.title = state.appMode == .minimal ? "Switch to Productivity Mode" : "Switch to Minimal Mode"
        }
    }
    
    @objc private func openSettingsAction() {
        NSApp.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }
    
    @objc func showSettingsWindow() {
        openSettingsCentered()
    }
    
    func openSettingsCentered() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    private func handleZenModeToggle() {
        let state = ZenithState.shared
        if state.zenModeEnabled {
            if state.zenModeHidden {
                state.zenModeHidden = false
                forceShowDock()
            } else {
                state.zenModeHidden = true
                hideDockCompletely()
            }
        } else {
            forceShowDock()
        }
    }
    
    private func handlePulseShortcut() {
        NotificationCenter.default.post(name: .zenithPulseRequested, object: nil)
    }
    
    private func forceShowDock() {
        if let nativeDockView = dockView as? NativeRadialDockView {
            nativeDockView.forceShowNotch()
        } else if let listDockView = dockView as? ListDockView {
            listDockView.showFromExternal()
        }
    }
    
    private func hideDockCompletely() {
        if let nativeDockView = dockView as? NativeRadialDockView {
            nativeDockView.hideNotchCompletely()
        } else if let listDockView = dockView as? ListDockView {
            listDockView.hideFromExternal()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
