import AppKit
import SwiftUI
import Combine

class ZenithWindow: NSWindow, ObservableObject {
    @Published var isHovering: Bool = false
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect, targetScreen: NSScreen?) {
        // The window must be tall enough to show the 'Drip' animation (slides down to y:10)
        // We make it 120px tall, positioned so the top of the window matches the top of the screen.
        let windowWidth: CGFloat = notchFrame.width
        let windowHeight: CGFloat = 120 
        
        let windowFrame = NSRect(
            x: notchFrame.origin.x,
            y: notchFrame.origin.y + notchFrame.height - windowHeight,
            width: windowWidth,
            height: windowHeight
        )
        
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
        
        setupTrackingArea(notchFrame: notchFrame)
        
        self.orderFrontRegardless()
    }

    private func setupTrackingArea(notchFrame: CGRect) {
        guard let contentView = self.contentView else { return }
        
        if let existing = trackingArea {
            contentView.removeTrackingArea(existing)
        }
        
        // Invisible 'tripwire' at the very top (2px tall)
        // In local coordinates of the 120px tall window, local y for top is windowHeight - 2
        let trackingRect = NSRect(x: 0, y: 118, width: notchFrame.width, height: 2)
        
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
        withAnimation {
            isHovering = true
        }
    }

    override func mouseExited(with event: NSEvent) {
        withAnimation {
            isHovering = false
        }
    }
    
    func pulse() {
        isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isPulsing = false
        }
    }
}
