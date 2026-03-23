import AppKit
import Combine

class QuickActionsPanel: NSPanel {
    private var actions: [QuickAction] = []
    private var buttons: [NSButton] = []
    private var onActionSelected: ((QuickActionType) -> Void)?
    private var onDismiss: (() -> Void)?
    
    private let actionHeight: CGFloat = 32
    private let actionSpacing: CGFloat = 4
    private let padding: CGFloat = 8
    
    private var trackingArea: NSTrackingArea?
    private var isMouseInside = false
    
    init(actions: [QuickAction], onAction: @escaping (QuickActionType) -> Void, onDismiss: @escaping () -> Void) {
        self.actions = actions
        self.onActionSelected = onAction
        self.onDismiss = onDismiss
        
        let contentWidth: CGFloat = 180
        let contentHeight = CGFloat(actions.count) * actionHeight + CGFloat(actions.count - 1) * actionSpacing + padding * 2
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: contentWidth, height: contentHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupUI()
        setupTracking()
    }
    
    private func setupWindow() {
        self.isFloatingPanel = true
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isReleasedWhenClosed = false
        self.hidesOnDeactivate = false
    }
    
    private func setupUI() {
        let containerView = NSView(frame: self.contentView!.bounds)
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        containerView.layer?.cornerRadius = 10
        containerView.layer?.borderWidth = 1
        containerView.layer?.borderColor = NSColor.separatorColor.cgColor
        
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = actionSpacing
        
        for action in actions {
            let button = createActionButton(for: action)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding)
        ])
        
        self.contentView = containerView
    }
    
    private func createActionButton(for action: QuickAction) -> NSButton {
        let button = NSButton()
        button.title = action.title
        button.bezelStyle = .inline
        button.isBordered = false
        button.font = NSFont.systemFont(ofSize: 13)
        button.imagePosition = .imageLeading
        button.alignment = .left
        button.contentTintColor = .labelColor
        
        if let symbolImage = NSImage(systemSymbolName: action.icon, accessibilityDescription: action.title) {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            button.image = symbolImage.withSymbolConfiguration(config)
        }
        
        button.target = self
        button.action = #selector(actionButtonClicked(_:))
        button.tag = actions.firstIndex(where: { $0.id == action.id }) ?? 0
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: actionHeight),
            button.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        return button
    }
    
    @objc private func actionButtonClicked(_ sender: NSButton) {
        let index = sender.tag
        guard index < actions.count else { return }
        
        let action = actions[index]
        onActionSelected?(action.action)
        close()
    }
    
    private func setupTracking() {
        trackingArea = NSTrackingArea(
            rect: self.contentView!.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        self.contentView?.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        isMouseInside = true
    }
    
    override func mouseExited(with event: NSEvent) {
        isMouseInside = false
        scheduleDismiss()
    }
    
    private var dismissTimer: Timer?
    
    private func scheduleDismiss() {
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self, !self.isMouseInside else { return }
            self.onDismiss?()
            self.close()
        }
    }
    
    func displayAt(anchorRect: NSRect, on screen: NSScreen? = nil) {
        let targetScreen = screen ?? NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = targetScreen.visibleFrame
        
        var origin = NSPoint(
            x: anchorRect.midX - frame.width / 2,
            y: anchorRect.minY - frame.height - 8
        )
        
        if origin.x < screenFrame.minX {
            origin.x = screenFrame.minX + 8
        } else if origin.x + frame.width > screenFrame.maxX {
            origin.x = screenFrame.maxX - frame.width - 8
        }
        
        if origin.y < screenFrame.minY {
            origin.y = anchorRect.maxY + 8
        }
        
        setFrameOrigin(origin)
        orderFront(nil)
        makeKey()
    }
    
    override func close() -> Void {
        dismissTimer?.invalidate()
        super.close()
    }
}

protocol QuickActionsPanelDelegate: AnyObject {
    func quickActionsPanel(_ panel: QuickActionsPanel, didSelectAction action: QuickActionType)
    func quickActionsPanelDidDismiss(_ panel: QuickActionsPanel)
}
