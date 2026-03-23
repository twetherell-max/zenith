import AppKit

class QuickNoteWindow: NSPanel {
    private let textField: NSTextField
    private let onSave: (String) -> Void
    private let onCancel: () -> Void
    private var autoCloseTimer: Timer?
    
    init(onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        
        self.textField = NSTextField(frame: .zero)
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 80),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupUI()
        positionWindow()
        
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleCancelNote()
        }
    }
    
    private func setupWindow() {
        self.title = "Quick Note"
        self.isFloatingPanel = true
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isReleasedWhenClosed = false
    }
    
    private func setupUI() {
        let contentView = NSView(frame: self.contentView!.bounds)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        contentView.layer?.cornerRadius = 10
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholderString = "Type your note..."
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.isBordered = true
        textField.bezelStyle = .roundedBezel
        textField.focusRingType = .none
        textField.delegate = self
        
        let buttonStack = NSStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 8
        
        let saveButton = NSButton(title: "Save", target: self, action: #selector(handleSaveNote))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(handleCancelNote))
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        
        buttonStack.addArrangedSubview(NSView())
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        
        contentView.addSubview(textField)
        contentView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            buttonStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        self.contentView = contentView
    }
    
    private func positionWindow() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowSize = self.frame.size
        
        let x = screenFrame.midX - windowSize.width / 2
        let y = screenFrame.midY - windowSize.height / 2 + 100
        
        self.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @objc private func handleSaveNote() {
        autoCloseTimer?.invalidate()
        let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        close()
        onSave(text)
    }
    
    @objc private func handleCancelNote() {
        autoCloseTimer?.invalidate()
        close()
        onCancel()
    }
    
    func show() {
        textField.stringValue = ""
        makeFirstResponder(textField)
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override func close() -> Void {
        autoCloseTimer?.invalidate()
        super.close()
    }
}

extension QuickNoteWindow: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            handleSaveNote()
            return true
        }
        return false
    }
}
