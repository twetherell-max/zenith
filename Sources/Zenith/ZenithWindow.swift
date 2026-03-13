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
        
        // Center the 400x400 window on the target screen
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 400
        let x = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
        let y = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
        let windowFrame = NSRect(x: x, y: y, width: windowWidth, height: windowHeight)
        
        print("Targeting Screen: \(screen.localizedName) with Frame: \(screen.frame)")
        
        super.init(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = true
        self.backgroundColor = .green
        self.alphaValue = 1.0
        self.level = .screenSaver
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.canHide = false
        self.isExcludedFromWindowsMenu = false
        self.hidesOnDeactivate = false
        
        print("FORCED Zenith Window Frame: \(self.frame)")
        
        let hostingView = NSHostingView(rootView: ZenithDropletView(isHovering: Binding(get: { self.isHovering }, set: { self.isHovering = $0 }), isPulsing: Binding(get: { self.isPulsing }, set: { self.isPulsing = $0 })))
        self.contentView = hostingView
        
        // setupTrackingArea(notchFrame: notchFrame) // Disabled for debug
        
        self.orderFrontRegardless()
    }

    private func setupTrackingArea(notchFrame: CGRect) {
        guard let contentView = self.contentView else { return }
        
        if let existing = trackingArea {
            contentView.removeTrackingArea(existing)
        }
        
        // Tracking area is still at the top of the notch
        // In local coordinates of the window's contentView
        let trackingRect = NSRect(x: 0, y: 100 + notchFrame.height - 2, width: notchFrame.width, height: 2)
        
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
