import AppKit
import SwiftUI
import Combine

class ZenithWindow: NSWindow, ObservableObject {
    @Published var isHovering: Bool = false
    @Published var isPulsing: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect) {
        // We make the window larger than the notch to allow for the animation space
        let windowFrame = NSRect(
            x: notchFrame.origin.x,
            y: notchFrame.origin.y - 100, // Extra space below for the drip
            width: notchFrame.width,
            height: notchFrame.height + 100 // Extra space above for starting position
        )
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let hostingView = NSHostingView(rootView: ZenithDropletView(isHovering: Binding(get: { self.isHovering }, set: { self.isHovering = $0 }), isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })))
        self.contentView = hostingView
        
        setupTrackingArea(notchFrame: notchFrame)
    }

    private func setupTrackingArea(notchFrame: CGRect) {
        if let existing = trackingArea {
            contentView?.removeTrackingArea(existing)
        }
        
        // Tracking area is still at the top of the notch
        // In local coordinates of the window's contentView
        // The window's y starts 100 points below the notch's y
        let trackingRect = NSRect(x: 0, y: 100 + notchFrame.height - 2, width: notchFrame.width, height: 2)
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect
        ]
        
        let area = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
        contentView?.addTrackingArea(area)
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
