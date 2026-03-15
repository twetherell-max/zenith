import AppKit
import SwiftUI
import Combine

class ZenithHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        let state = ZenithState.shared
        
        // 1. THE NOTCH (CENTER TOP)
        let notchWidth: CGFloat = 200
        let notchHeight: CGFloat = 40
        let notchRect = NSRect(x: (self.bounds.width - notchWidth) / 2, y: self.bounds.height - notchHeight, width: notchWidth, height: notchHeight)
        
        if notchRect.contains(point) {
            return super.hitTest(point)
        }
        
        // 2. THE BUTTONS (SMILE ARC)
        if !state.isExpanded && !state.isSettingsOpen {
            return nil // SILHOUETTE PASSTHROUGH
        }
        
        for id in 1...3 {
            let xOffset = CGFloat(id - 2) * state.arcSpread
            let yOffset = (abs(xOffset) * -0.2) + state.dropDepth // SMILE MATH ALIGNMENT
            
            let centerX = self.bounds.width / 2 + xOffset
            let centerY = self.bounds.height - yOffset
            
            let hWidth: CGFloat = state.iconSize + 15
            let buttonRect = NSRect(x: centerX - hWidth, y: centerY - hWidth, width: hWidth * 2, height: hWidth * 2)
            
            if buttonRect.contains(point) {
                return super.hitTest(point)
            }
        }
        
        return nil // GHOST MODE ACTIVE
    }
}

class ZenithWindow: NSWindow {
    let targetScreen: NSScreen?
    private var cancellables = Set<AnyCancellable>()
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect, targetScreen: NSScreen?) {
        self.targetScreen = targetScreen
        // Force strictly to the built-in display (Retina) for frame calculations
        let screen = NSScreen.screens.first ?? targetScreen ?? NSScreen.main ?? NSScreen.screens[0]
        let visibleFrame = screen.visibleFrame
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 200
        
        let centerX = visibleFrame.origin.x + (visibleFrame.width - windowWidth) / 2
        let topY = visibleFrame.origin.y + visibleFrame.height
        
        // Initial "Peeking" frame: 5px visible on screen
        let windowFrame = NSRect(x: centerX, y: topY - 5, width: windowWidth, height: windowHeight)
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear // TOTAL TRANSPARENCY RESTORED
        self.hasShadow = false // REMOVE APPKIT BLACK BOX SHADOW
        self.title = "ZenithWindow" // FOR IDENTIFICATION
        self.alphaValue = 1.0
        self.level = .statusBar // HIGHER THAN ALL WINDOWS, LOWER THAN TOOL TIPS
        self.ignoresMouseEvents = false
        
        // REACIVE FRAME SYNC: Observe global expansion state
        ZenithState.shared.$isExpanded
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateWindowFrame() }
            .store(in: &cancellables)
            
        ZenithState.shared.$isSettingsOpen
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateWindowFrame() }
            .store(in: &cancellables)

        // APPKIT FORCED RENDER FLUSHER
        ZenithState.shared.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                // Force AppKit to repaint the entire hardware buffer surface manually instantly
                self?.contentView?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        let rootView = ZenithDropletView(
            isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })
        )
        
        let hostingView = ZenithHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        hostingView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height] // FORCE RESIZE TO WINDOW
        hostingView.layer?.masksToBounds = false
        
        self.contentView = hostingView
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.isGeometryFlipped = false
        
        print(">>> ZENITH: NSHostingView bridge established. ContentView: \(String(describing: self.contentView))")
        
        setupTrackingArea()
        
        // KVO LIVE STATE SYNC
        UserDefaults.standard.addObserver(self, forKeyPath: "isSettingsOpen", options: [.new], context: nil)
        
        self.orderFrontRegardless()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "isSettingsOpen")
    }

    private func setupTrackingArea() {
        guard let contentView = self.contentView else { return }
        
        if let existing = trackingArea {
            contentView.removeTrackingArea(existing)
        }
        
        let trackingRect = contentView.bounds
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect
        ]
        
        let area = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
        contentView.addTrackingArea(area)
        self.trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        // Handled by ZenithDropletView.onHover -> ZenithState.isExpanded
    }

    override func mouseExited(with event: NSEvent) {
        // Handled by ZenithDropletView.onHover -> ZenithState.isExpanded
    }

    private func updateWindowFrame() {
        // Force strictly to the built-in display (Retina)
        let screen = NSScreen.screens.first ?? self.screen ?? NSScreen.main ?? NSScreen.screens[0]
        let visibleFrame = screen.visibleFrame
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 200
        
        let centerX = visibleFrame.origin.x + (visibleFrame.width - windowWidth) / 2
        let topY = visibleFrame.origin.y + visibleFrame.height
        
        let isExpanded = ZenithState.shared.isExpanded || ZenithState.shared.isSettingsOpen
        
        // When hovering or Settings are open, slide the window down by 195px so it's fully on screen (200px down)
        let targetY = isExpanded ? topY - 200 : topY - 5
        let targetFrame = NSRect(x: centerX, y: targetY, width: windowWidth, height: windowHeight)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(targetFrame, display: true)
        }
    }
    
    // LISTEN TO APPKIT/USERDEFAULTS CHANGES
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isSettingsOpen" {
            DispatchQueue.main.async {
                self.updateWindowFrame()
            }
        }
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func pulse() {
        self.isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPulsing = false
        }
    }
}
