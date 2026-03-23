import AppKit

class FocusDimmingWindow: NSWindow {
    static let shared = FocusDimmingWindow()
    
    private var dimmingView: FocusDimmingView!
    
    private init() {
        guard let screen = NSScreen.main else {
            super.init(
                contentRect: .zero,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            return
        }
        
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
    }
    
    private func setupWindow() {
        level = .screenSaver
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        dimmingView = FocusDimmingView(frame: contentView?.bounds ?? .zero)
        dimmingView.autoresizingMask = [.width, .height]
        contentView?.addSubview(dimmingView)
    }
    
    func show(animated: Bool = true) {
        guard ZenithState.shared.focusDimmingEnabled else { return }
        
        if !isVisible {
            orderFront(nil)
        }
        
        if animated {
            dimmingView.alphaValue = 0
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                dimmingView.animator().alphaValue = 1.0
            }
        } else {
            dimmingView.alphaValue = 1.0
        }
    }
    
    func hide(animated: Bool = true) {
        if !isVisible { return }
        
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                dimmingView.animator().alphaValue = 0.0
            } completionHandler: {
                self.orderOut(nil)
            }
        } else {
            orderOut(nil)
        }
    }
    
    func updateForScreen(_ screen: NSScreen?) {
        guard let screen = screen ?? NSScreen.main else { return }
        setFrame(screen.frame, display: true)
    }
}

class FocusDimmingView: NSView {
    private let dimOpacity: CGFloat = 0.3
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(dimOpacity).setFill()
        dirtyRect.fill()
        
        let dockRegion = calculateDockRegion()
        NSColor.clear.setFill()
        dockRegion.fill()
    }
    
    private func calculateDockRegion() -> NSRect {
        let screen = window?.screen ?? NSScreen.main
        let screenFrame = screen?.frame ?? NSRect(x: 0, y: 0, width: 1000, height: 800)
        
        let notchWidth: CGFloat = 150
        let barHeight: CGFloat = 12
        let dockHeight: CGFloat = 100
        
        let centerX = screenFrame.midX
        
        let dockRect = NSRect(
            x: centerX - notchWidth / 2,
            y: screenFrame.height - barHeight - dockHeight,
            width: notchWidth,
            height: barHeight + dockHeight
        )
        
        return dockRect
    }
    
    override var isFlipped: Bool {
        return false
    }
}
