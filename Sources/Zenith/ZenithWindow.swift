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
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 400
        let centerX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
        let topY = screenFrame.origin.y + screenFrame.height
        
        // Initial "Peeking" frame: 5px visible on screen, 395px above
        let windowFrame = NSRect(x: centerX, y: topY - 5, width: windowWidth, height: windowHeight)
        print("WINDOW FRAME (INIT): \(windowFrame)")
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Critical Transparency Settings
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        
        self.level = .screenSaver // HIGHEST PRIORITY LEVEL
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.canHide = false
        self.isExcludedFromWindowsMenu = true
        self.hidesOnDeactivate = false
        
        let hostingView = NSHostingView(rootView: ZenithDropletView(isHovering: Binding(get: { self.isHovering }, set: { self.isHovering = $0 }), isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })))
        hostingView.layer?.masksToBounds = false
        self.contentView = hostingView
        
        setupTrackingArea()
        
        self.orderFrontRegardless()
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
        print("WINDOW FRAME (BEFORE UPDATE): \(self.frame)")
        guard let screen = self.screen else { return }
        let screenFrame = screen.frame
        let windowWidth: CGFloat = 800
        let windowHeight: CGFloat = 400
        let centerX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
        let topY = screenFrame.origin.y + screenFrame.height
        
        // When hovering, slide the window down by 395px so it's fully on screen (400px tall)
        let targetY = isHovering ? topY - windowHeight : topY - 5
        let targetFrame = NSRect(x: centerX, y: targetY, width: windowWidth, height: windowHeight)
        print("WINDOW FRAME (TARGET): \(targetFrame)")
        
        // TELEPORT (No Animation)
        self.setFrame(targetFrame, display: true)
    }

    func pulse() {
        self.isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPulsing = false
        }
    }
}
