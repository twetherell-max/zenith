import AppKit
import Combine

class ZenithWindow: NSWindow, ObservableObject {
    @Published var isHovering: Bool = false
    
    private var trackingArea: NSTrackingArea?

    init(notchFrame: CGRect) {
        // The window itself should probably cover the same area as the notch, 
        // but the tracking area is specifically the top 2 pixels.
        super.init(
            contentRect: notchFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        setupTrackingArea(notchFrame: notchFrame)
    }

    private func setupTrackingArea(notchFrame: CGRect) {
        if let existing = trackingArea {
            contentView?.removeTrackingArea(existing)
        }
        
        // Define tracking area as the top 2 pixels of the notch frame
        // In local coordinates of the window's contentView
        let trackingRect = NSRect(x: 0, y: notchFrame.height - 2, width: notchFrame.width, height: 2)
        
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
        isHovering = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovering = false
    }
}
