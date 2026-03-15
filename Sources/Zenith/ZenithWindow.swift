import AppKit
import SwiftUI
import Combine

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
        let windowHeight: CGFloat = 400
        
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
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow))) // ABSOLUTE FOREGROUND
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
        .environmentObject(ZenithState.shared) // INJECT LIVE MEMORY PIPELINE
        
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        hostingView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height] // FORCE RESIZE TO WINDOW
        hostingView.layer?.masksToBounds = false
        
        self.contentView = hostingView
        
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
        let windowHeight: CGFloat = 400
        
        let centerX = visibleFrame.origin.x + (visibleFrame.width - windowWidth) / 2
        let topY = visibleFrame.origin.y + visibleFrame.height
        
        let isExpanded = ZenithState.shared.isExpanded || ZenithState.shared.isSettingsOpen
        
        // When hovering or Settings are open, slide the window down by 395px so it's fully on screen (400px down to accommodate massive hitbox)
        let targetY = isExpanded ? topY - 400 : topY - 5
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

    func pulse() {
        self.isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPulsing = false
        }
    }
}
