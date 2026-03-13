import AppKit
import SwiftUI
import Combine

class ZenithWindow: NSWindow, ObservableObject {
    @Published var isHovering: Bool = false
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect, targetScreen: NSScreen?) {
        // Centered 400x400 window for debugging permissions and visibility
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 400
        let windowFrame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .borderless],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Zenith Permission Debug"
        self.isOpaque = true
        self.backgroundColor = .green
        self.hasShadow = true
        self.level = .floating
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces]
        
        self.canHide = false
        self.isExcludedFromWindowsMenu = false
        self.hidesOnDeactivate = false
        
        self.center()
        
        let hostingView = NSHostingView(rootView: ZenithDropletView(isHovering: Binding(get: { self.isHovering }, set: { self.isHovering = $0 }), isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })))
        self.contentView = hostingView
        
        // setupTrackingArea(notchFrame: notchFrame) // Disabled for debug
        
        self.makeKeyAndOrderFront(nil)
        self.setIsVisible(true)
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
