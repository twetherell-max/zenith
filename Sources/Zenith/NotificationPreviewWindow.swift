import AppKit

class NotificationPreviewWindow: NSWindow {
    static let shared = NotificationPreviewWindow()
    
    private var previewView: NotificationPreviewView!
    
    private init() {
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 120
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
    }
    
    private func setupWindow() {
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        previewView = NotificationPreviewView(frame: contentView?.bounds ?? .zero)
        previewView.autoresizingMask = [.width, .height]
        contentView?.addSubview(previewView)
    }
    
    func showNotifications(_ notifications: [NotificationItem], below barFrame: NSRect) {
        guard !notifications.isEmpty else {
            hideWindow()
            return
        }
        
        previewView.update(with: notifications)
        
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = min(120, CGFloat(notifications.count) * 40 + 20)
        
        setContentSize(NSSize(width: windowWidth, height: windowHeight))
        
        let centerX = barFrame.midX - windowWidth / 2
        let windowY = barFrame.minY - windowHeight - 10
        
        setFrameOrigin(NSPoint(x: centerX, y: windowY))
        
        if !isVisible {
            alphaValue = 0
            orderFront(nil)
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        }
    }
    
    func hideWindow() {
        guard isVisible else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            self.animator().alphaValue = 0.0
        } completionHandler: {
            self.orderOut(nil)
        }
    }
}

class NotificationPreviewView: NSView {
    private var notifications: [NotificationItem] = []
    private var stackView: NSStackView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.85).cgColor
        layer?.cornerRadius = 12
        layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        layer?.borderWidth = 1
        
        stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }
    
    func update(with notifications: [NotificationItem]) {
        self.notifications = Array(notifications.prefix(3))
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for notification in self.notifications {
            let row = createNotificationRow(notification)
            stackView.addArrangedSubview(row)
        }
    }
    
    private func createNotificationRow(_ notification: NotificationItem) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = NSTextField(labelWithString: notification.title)
        titleLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bodyLabel = NSTextField(labelWithString: notification.body)
        bodyLabel.font = NSFont.systemFont(ofSize: 10)
        bodyLabel.textColor = NSColor.white.withAlphaComponent(0.7)
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            
            bodyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            bodyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
