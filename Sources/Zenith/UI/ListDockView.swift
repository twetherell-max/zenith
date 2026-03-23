import AppKit
import Combine

class ListDockView: NSView {
    private var iconViews: [DockIconView] = []
    private var barView: BarView!
    private var iconContainerView: NSView!
    weak var delegate: NativeRadialDockDelegate?
    
    private var state: ZenithState { ZenithState.shared }
    private var cancellables = Set<AnyCancellable>()
    
    private var isHovering = false
    private var isInteracting = false
    private var interactionTimer: Timer?
    private var previewModeActive = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
        setupHoverDetection()
        observeStateChanges()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupHoverDetection()
        observeStateChanges()
    }
    
    private func setupViews() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        iconContainerView = NSView()
        iconContainerView.wantsLayer = true
        iconContainerView.layer?.backgroundColor = NSColor.clear.cgColor
        iconContainerView.isHidden = true
        addSubview(iconContainerView)
        
        barView = BarView()
        addSubview(barView)
        
        let topBox = NSView()
        topBox.wantsLayer = true
        topBox.layer?.backgroundColor = NSColor.clear.cgColor
        topBox.identifier = NSUserInterfaceItemIdentifier("topBox")
        addSubview(topBox)
    }
    
    private func setupHoverDetection() {
        let expandedRect = NSRect(
            x: 0,
            y: -200,
            width: bounds.width,
            height: bounds.height + 250
        )
        let trackingArea = NSTrackingArea(
            rect: expandedRect,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect, .enabledDuringMouseDrag],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        setupHoverDetection()
    }
    
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    
    override func mouseEntered(with event: NSEvent) {
        isInteracting = true
        isHovering = true
        if !previewModeActive {
            showIcons()
        }
        interactionTimer?.invalidate()
    }
    
    override func mouseExited(with event: NSEvent) {
        isInteracting = false
        interactionTimer?.invalidate()
        interactionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.isInteracting && !ZenithState.shared.isSettingsOpen {
                self.isHovering = false
                self.hideIcons()
                if !self.previewModeActive {
                    for iconView in self.iconViews {
                        iconView.layer?.transform = CATransform3DIdentity
                    }
                }
            }
        }
    }
    
    private func showIcons() {
        iconContainerView.isHidden = false
        iconContainerView.alphaValue = 0
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            self.iconContainerView.animator().alphaValue = 1.0
        }
    }
    
    private func hideIcons() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            self.iconContainerView.animator().alphaValue = 0.0
        } completionHandler: {
            if !ZenithState.shared.isSettingsOpen {
                self.iconContainerView.isHidden = true
            }
        }
    }
    
    func enterPreviewMode() {
        previewModeActive = true
        showIcons()
        for iconView in iconViews {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                iconView.animator().layer?.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            }
        }
    }
    
    func exitPreviewMode() {
        previewModeActive = false
        for iconView in iconViews {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                iconView.animator().layer?.transform = CATransform3DIdentity
            }
        }
        hideIcons()
    }
    
    func showFromExternal() {
        if !iconContainerView.isHidden && iconContainerView.alphaValue > 0 { return }
        showIcons()
    }
    
    func hideFromExternal() {
        hideIcons()
    }
    
    func isMouseInIconArea() -> Bool {
        guard let window = self.window, let _ = window.screen else { return false }
        let mouseLocation = NSEvent.mouseLocation
        let windowFrame = window.frame
        
        let iconAreaRect = NSRect(
            x: windowFrame.origin.x,
            y: windowFrame.origin.y,
            width: windowFrame.width,
            height: windowFrame.height
        )
        
        return iconAreaRect.contains(mouseLocation) && !iconContainerView.isHidden && iconContainerView.alphaValue > 0
    }
    
    private func observeStateChanges() {
        ZenithState.shared.$dockButtons
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$iconSize
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$accentColor
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$dockOpacity
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$contrastLevel
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$borderWidth
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$hoverLift
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$dockStyle
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$notchWidth
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$barOpacity
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.barView.updateAppearance() }
            .store(in: &cancellables)
        
        ZenithState.shared.$barHeight
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$useWhiteOutline
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$musicDisplayMode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$isSettingsOpen
            .receive(on: RunLoop.main)
            .sink { [weak self] isOpen in
                if isOpen {
                    self?.enterPreviewMode()
                } else {
                    self?.exitPreviewMode()
                }
            }
            .store(in: &cancellables)
    }
    
    func updateLayout() {
        let cx = bounds.width / 2
        
        if let topBox = subviews.first(where: { $0.identifier?.rawValue == "topBox" }) {
            let topBoxWidth: CGFloat = 100
            let topBoxHeight: CGFloat = 350
            let topBoxX = cx - topBoxWidth / 2
            let topBoxY = bounds.height - topBoxHeight
            topBox.frame = NSRect(
                x: topBoxX,
                y: topBoxY,
                width: topBoxWidth,
                height: topBoxHeight
            )
        }
        
        let barWidth = max(CGFloat(state.notchWidth), 100)
        let barHeight = CGFloat(state.barHeight)
        let barY = bounds.height - barHeight - 10
        barView.frame = NSRect(
            x: cx - barWidth / 2,
            y: barY,
            width: barWidth,
            height: barHeight
        )
        barView.updateAppearance()
        
        updateIconPositions()
    }
    
    private func updateIconPositions() {
        let buttons = state.dockButtons.filter { $0.isEnabled }
        let iconSize = CGFloat(state.iconSize)
        let spacing: CGFloat = 8
        
        let totalWidth = CGFloat(buttons.count) * iconSize + CGFloat(buttons.count - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2
        
        let iconStartY = barView.frame.origin.y - iconSize - 5
        
        for (index, button) in buttons.enumerated() {
            let x = startX + CGFloat(index) * (iconSize + spacing)
            
            if index < iconViews.count {
                iconViews[index].frame = NSRect(x: x, y: iconStartY, width: iconSize, height: iconSize)
                iconViews[index].configure(with: button, state: state, iconIndex: index)
                iconViews[index].delegate = self
            } else {
                let iconView = DockIconView()
                iconView.frame = NSRect(x: x, y: iconStartY, width: iconSize, height: iconSize)
                iconView.configure(with: button, state: state, iconIndex: index)
                iconView.delegate = self
                iconContainerView.addSubview(iconView)
                iconViews.append(iconView)
            }
        }
        
        for index in buttons.count..<iconViews.count {
            iconViews[index].isHidden = true
        }
        
        iconContainerView.frame = NSRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: barView.frame.origin.y
        )
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let localPoint = convert(point, from: nil)
        
        if barView.frame.contains(localPoint) {
            return barView
        }
        
        if !iconContainerView.isHidden || ZenithState.shared.isSettingsOpen {
            let pointInContainer = convert(localPoint, to: iconContainerView)
            for iconView in iconViews where !iconView.isHidden {
                if iconView.frame.contains(pointInContainer) {
                    return iconView
                }
            }
        }
        
        if let topBox = subviews.first(where: { $0.identifier?.rawValue == "topBox" }),
           topBox.frame.contains(localPoint) {
            return topBox
        }
        
        return nil
    }
}

extension ListDockView: DockIconViewDelegate {
    func iconClicked(_ icon: DockIconView, button: DockButton) {
        delegate?.iconClicked(button: button)
    }
}
