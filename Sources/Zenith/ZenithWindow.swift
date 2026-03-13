import AppKit
import SwiftUI
import Combine

class ZenithWindow: NSWindow, ObservableObject {
    @Published var isHovering: Bool = false
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect, targetScreen: NSScreen?) {
        let screen = targetScreen ?? NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.frame
        let centerX = screenFrame.origin.x + (screenFrame.width - 200) / 2
        let topY = screenFrame.origin.y + screenFrame.height
        
        // Initial "Peeking" frame: 5px visible on screen, 75px above
        let windowFrame = NSRect(x: centerX, y: topY - 5, width: 200, height: 80)
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .screenSaver
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.canHide = false
        self.isExcludedFromWindowsMenu = true
        self.hidesOnDeactivate = false
        
        let hostingView = NSHostingView(rootView: ZenithDropletView(isHovering: Binding(get: { self.isHovering }, set: { self.isHovering = $0 }), isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })))
        self.contentView = hostingView
        
        setupTrackingArea()
        
        self.orderFrontRegardless()
    }

    private func setupTrackingArea() {
        guard let contentView = self.contentView else { return }
        
        if let existing = trackingArea {
            contentView.removeTrackingArea(existing)
        }
        
        // Tracking area covers the entire window, but since the window is mostly off-screen,
        // it effectively acts as a tripwire for the visible part.
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
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            self.isHovering = true
        }
        updateWindowFrame()
    }

    override func mouseExited(with event: NSEvent) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            self.isHovering = false
        }
        updateWindowFrame()
    }

    private func updateWindowFrame() {
        guard let screen = self.screen else { return }
        let screenFrame = screen.frame
        let centerX = screenFrame.origin.x + (screenFrame.width - 200) / 2
        let topY = screenFrame.origin.y + screenFrame.height
        
        // When hovering, slide the window down by 75px so it's fully on screen (80px tall)
        let targetY = isHovering ? topY - 80 : topY - 5
        let targetFrame = NSRect(x: centerX, y: targetY, width: 200, height: 80)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(targetFrame, display: true)
        }
    }

    func pulse() {
        self.isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPulsing = false
        }
    }
}
