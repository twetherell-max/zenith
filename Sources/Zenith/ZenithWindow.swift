import AppKit
import SwiftUI
import Combine

// THE SILHOUETTE ENGINE
class ZenithHitView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        // HIT TEST CHECK: return super.hitTest(point) if it's hitting a button
        let hitView = super.hitTest(point)
        
        // If the hit is the background container (self), return nil to passthrough.
        // If it's anything else (a button or SwiftUI view), return hitView.
        return hitView === self ? nil : hitView
    }
}

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
        
        // 2. THE BUTTONS
        if !state.isExpanded && !state.isSettingsOpen {
            return nil 
        }
        
        for id in 1...3 {
            let xOffset = CGFloat(id - 2) * state.arcSpread
            let yOffset = (abs(xOffset) * -0.2) + state.dropDepth 
            
            let centerX = self.bounds.width / 2 + xOffset
            let centerY = self.bounds.height - yOffset
            
            let hWidth: CGFloat = (state.iconSize + 15) 
            let buttonRect = NSRect(x: centerX - hWidth, y: centerY - hWidth, width: hWidth * 2, height: hWidth * 2)
            
            if buttonRect.contains(point) {
                return super.hitTest(point)
            }
        }
        
        return nil 
    }
}

class ZenithWindow: NSWindow {
    let targetScreen: NSScreen?
    private var cancellables = Set<AnyCancellable>()
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect, targetScreen: NSScreen?) {
        self.targetScreen = targetScreen
        let screen = NSScreen.screens.first ?? targetScreen ?? NSScreen.main ?? NSScreen.screens[0]
        let visibleFrame = screen.visibleFrame
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 200
        
        let centerX = visibleFrame.origin.x + (visibleFrame.width - windowWidth) / 2
        let topY = visibleFrame.origin.y + visibleFrame.height
        
        let windowFrame = NSRect(x: centerX, y: topY - 5, width: windowWidth, height: windowHeight)
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear 
        self.hasShadow = false 
        self.title = "ZenithWindow"
        self.level = .statusBar 
        self.ignoresMouseEvents = false
        self.isRestorable = false 
        
        ZenithState.shared.$isExpanded
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateWindowFrame() }
            .store(in: &cancellables)
            
        ZenithState.shared.$isSettingsOpen
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateWindowFrame() }
            .store(in: &cancellables)

        let rootView = ZenithDropletView(
            isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })
        )
        let hostingView = ZenithHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        hostingView.autoresizingMask = [.width, .height]
        
        // SET THE HIT VIEW AS CONTENT VIEW
        let container = ZenithHitView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        container.addSubview(hostingView)
        self.contentView = container
        
        setupTrackingArea()
    }

    private func setupTrackingArea() {
        guard let contentView = self.contentView else { return }
        if let existing = trackingArea { contentView.removeTrackingArea(existing) }
        let trackingRect = contentView.bounds
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let area = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
        contentView.addTrackingArea(area)
        self.trackingArea = area
    }

    private func updateWindowFrame() {
        let screen = NSScreen.screens.first ?? self.screen ?? NSScreen.main ?? NSScreen.screens[0]
        let visibleFrame = screen.visibleFrame
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 200
        let centerX = visibleFrame.origin.x + (visibleFrame.width - windowWidth) / 2
        let topY = visibleFrame.origin.y + visibleFrame.height
        let isExpanded = ZenithState.shared.isExpanded || ZenithState.shared.isSettingsOpen
        let targetY = isExpanded ? topY - 200 : topY - 5
        let targetFrame = NSRect(x: centerX, y: targetY, width: windowWidth, height: windowHeight)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(targetFrame, display: true)
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
