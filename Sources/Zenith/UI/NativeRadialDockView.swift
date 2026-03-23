import AppKit
import Combine

// MARK: - NativeRadialDockView (Container)
// The BAR is always visible at top
// The NOTCH (icons) is hidden until hover, then drops down as a unit
class NativeRadialDockView: NSView {
    private var iconViews: [DockIconView] = []
    private var barView: BarView!
    private var notchContainerView: NSView!
    weak var delegate: NativeRadialDockDelegate?
    
    private var state: ZenithState { ZenithState.shared }
    private var cancellables = Set<AnyCancellable>()
    
    private var isHovering = false
    private var isInteracting = false // Mouse is in the interaction area
    private var interactionTimer: Timer? // Timer to track when mouse leaves
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
        
        // NOTCH container - below bar
        notchContainerView = NSView()
        notchContainerView.wantsLayer = true
        notchContainerView.layer?.backgroundColor = NSColor.clear.cgColor
        notchContainerView.isHidden = true
        addSubview(notchContainerView)
        
        // BAR - always visible at top, rounded rectangle
        barView = BarView()
        addSubview(barView)
        
        // Top box - for hover detection only, nearly invisible
        let topBox = NSView()
        topBox.wantsLayer = true
        topBox.layer?.backgroundColor = NSColor.clear.cgColor
        topBox.identifier = NSUserInterfaceItemIdentifier("topBox")
        addSubview(topBox)
    }
    
    private func setupHoverDetection() {
        // Main container tracking area - expanded to cover entire hit area
        let expandedRect = NSRect(
            x: 0,
            y: -200,  // Extended 200px above bar
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
            showNotch()
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
                self.hideNotch()
                if !self.previewModeActive {
                    for iconView in self.iconViews {
                        iconView.layer?.transform = CATransform3DIdentity
                    }
                }
            }
        }
    }
    
    private func showNotch() {
        notchContainerView.isHidden = false
        notchContainerView.alphaValue = 0
        
        FocusDimmingWindow.shared.show()
        
        let state = ZenithState.shared
        if state.useSpringAnimations {
            SpringAnimator.animateSpringOpacity(
                layer: notchContainerView.layer!,
                to: 1.0,
                stiffness: state.springStiffness * 0.5,
                damping: state.springDamping
            )
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                self.notchContainerView.animator().alphaValue = 1.0
            }
        }
    }
    
    private func hideNotch() {
        let state = ZenithState.shared
        if state.useSpringAnimations {
            SpringAnimator.animateSpringOpacity(
                layer: notchContainerView.layer!,
                to: 0.0,
                stiffness: state.springStiffness * 0.5,
                damping: state.springDamping
            ) {
                if !ZenithState.shared.isSettingsOpen {
                    self.notchContainerView.isHidden = true
                }
            }
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.1
                self.notchContainerView.animator().alphaValue = 0.0
            } completionHandler: {
                if !ZenithState.shared.isSettingsOpen {
                    self.notchContainerView.isHidden = true
                }
            }
        }
        
        FocusDimmingWindow.shared.hide()
    }
    
    func forceShowNotch() {
        notchContainerView.isHidden = false
        notchContainerView.alphaValue = 1.0
        isHovering = true
        for iconView in iconViews {
            iconView.layer?.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
        }
        
        FocusDimmingWindow.shared.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            if !self.isInteracting && !ZenithState.shared.zenModeHidden {
                self.hideNotch()
                for iconView in self.iconViews {
                    iconView.layer?.transform = CATransform3DIdentity
                }
            }
        }
    }
    
    func hideNotchCompletely() {
        ZenithState.shared.zenModeHidden = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            self.notchContainerView.animator().alphaValue = 0.0
        } completionHandler: {
            self.notchContainerView.isHidden = true
        }
        for iconView in iconViews {
            iconView.layer?.transform = CATransform3DIdentity
        }
        
        FocusDimmingWindow.shared.hide()
    }
    
    private func enterPreviewMode() {
        previewModeActive = true
        showNotch()
        for iconView in iconViews {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                iconView.animator().layer?.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            }
        }
    }
    
    private func exitPreviewMode() {
        previewModeActive = false
        for iconView in iconViews {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                iconView.animator().layer?.transform = CATransform3DIdentity
            }
        }
        hideNotch()
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
        
        return iconAreaRect.contains(mouseLocation) && !notchContainerView.isHidden && notchContainerView.alphaValue > 0
    }
    
    func showNotchFromExternal() {
        if !notchContainerView.isHidden && notchContainerView.alphaValue > 0 { return }
        showNotch()
    }
    
    func hideNotchFromExternal() {
        hideNotch()
    }
    
    private func observeStateChanges() {
        ZenithState.shared.$dockButtons
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateLayout() }
            .store(in: &cancellables)
        
        ZenithState.shared.$arcSpread
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
        
        // Settings open state - keep notch visible
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
        
        // Top box - narrower width, centered on top (the T-shape top part)
        if let topBox = subviews.first(where: { $0.identifier?.rawValue == "topBox" }) {
            let topBoxWidth: CGFloat = 100  // Much narrower than window
            let topBoxHeight: CGFloat = 350  // Fill most of the extended area
            let topBoxX = cx - topBoxWidth / 2  // Centered
            let topBoxY = bounds.height - topBoxHeight  // At the very top
            topBox.frame = NSRect(
                x: topBoxX,
                y: topBoxY,
                width: topBoxWidth,
                height: topBoxHeight
            )
        }
        
        // BAR - always visible at top, rounded rectangle
        let barWidth = max(CGFloat(state.notchWidth), 100)
        let barHeight = CGFloat(state.barHeight)
        // Position bar at the TOP of the window - 10px from top edge
        let barY = bounds.height - barHeight - 10
        barView.frame = NSRect(
            x: cx - barWidth / 2,
            y: barY,
            width: barWidth,
            height: barHeight
        )
        barView.updateAppearance()
        
        // NOTCH container - spans the window for icon positioning
        // But hover detection is handled separately in hitTest
        notchContainerView.frame = NSRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: barView.frame.origin.y
        )
        
        updateIconPositions()
    }
    
    private func updateIconPositions() {
        let cx = notchContainerView.bounds.width / 2
        let r = CGFloat(state.arcSpread)
        let buttons = state.dockButtons.filter { $0.isEnabled }
        
        let angleStep = buttons.count > 1 ? CGFloat.pi / CGFloat(buttons.count - 1) : CGFloat.pi
        
        // Icon starting position - RIGHT BELOW the bar (moved up)
        // Start icons 5px below the bar
        let startY = barView.frame.origin.y - 5
        
        for (index, button) in buttons.enumerated() {
            // Smile arc: from left to right
            // angle goes from PI to 0
            let angle = CGFloat.pi - CGFloat(index) * angleStep
            
            // X position: cos(angle) gives left-to-right
            let x = cx + r * cos(angle)
            
            // Y position: sin(angle) gives the U/smile shape
            // sin(PI) = 0, sin(PI/2) = 1, sin(0) = 0
            // Middle icons (angle ≈ PI/2) have highest sin = lowest on screen
            let y = startY - r * sin(angle)
            
            let iconSize = CGFloat(state.iconSize)
            let iconY = y - iconSize / 2
            
            if index < iconViews.count {
                iconViews[index].frame = NSRect(x: x - iconSize/2, y: iconY, width: iconSize, height: iconSize)
                iconViews[index].configure(with: button, state: state, iconIndex: index)
                iconViews[index].delegate = self
            } else {
                let iconView = DockIconView()
                iconView.frame = NSRect(x: x - iconSize/2, y: iconY, width: iconSize, height: iconSize)
                iconView.configure(with: button, state: state, iconIndex: index)
                iconView.delegate = self
                notchContainerView.addSubview(iconView)
                iconViews.append(iconView)
            }
        }
        
        // Hide extra icon views
        for index in buttons.count..<iconViews.count {
            iconViews[index].isHidden = true
        }
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let localPoint = convert(point, from: nil)
        
        // Check if point is on BAR - CAPTURE click
        if barView.frame.contains(localPoint) {
            return barView
        }
        
        // Check if point is on ICONS - CAPTURE click
        if !notchContainerView.isHidden || ZenithState.shared.isSettingsOpen {
            // Check in notchContainerView's coordinate space
            let pointInNotchContainer = convert(localPoint, to: notchContainerView)
            for iconView in iconViews where !iconView.isHidden {
                if iconView.frame.contains(pointInNotchContainer) {
                    return iconView
                }
            }
        }
        
        // Check if point is on TOPBOX - CAPTURE click
        if let topBox = subviews.first(where: { $0.identifier?.rawValue == "topBox" }),
           topBox.frame.contains(localPoint) {
            return topBox
        }
        
        // EVERYTHING ELSE - PASS THROUGH (return nil) - creates stencil holes
        return nil
    }
}

extension NativeRadialDockView: DockIconViewDelegate {
    func iconClicked(_ icon: DockIconView, button: DockButton) {
        delegate?.iconClicked(button: button)
    }
}

protocol NativeRadialDockDelegate: AnyObject {
    func iconClicked(button: DockButton)
}

// MARK: - BarView
// The always-visible rounded bar at the top
class BarView: NSView {
    weak var delegate: NotchClickAreaDelegate?
    private var trackingArea: NSTrackingArea?
    private var aiButton: NSButton?
    private var notificationIndicator: CALayer?
    private var pulseAnimation: CAAnimation?
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = false
        updateAppearance()
        setupTrackingArea()
        setupAIButton()
        setupNotificationIndicator()
        observeAIState()
        observeNotificationState()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.masksToBounds = false
        updateAppearance()
        setupTrackingArea()
        setupAIButton()
        setupNotificationIndicator()
        observeAIState()
        observeNotificationState()
    }
    
    private func setupAIButton() {
        let button = NSButton(frame: .zero)
        button.bezelStyle = .inline
        button.isBordered = false
        button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Quick Query")
        button.imagePosition = .imageOnly
        button.contentTintColor = .orange
        button.target = self
        button.action = #selector(openAIQuery)
        button.toolTip = "Quick Query AI"
        button.isHidden = !ZenithState.shared.aiEnabled
        self.addSubview(button)
        aiButton = button
    }
    
    private func observeAIState() {
        ZenithState.shared.$aiEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.aiButton?.isHidden = !enabled
            }
            .store(in: &cancellables)
    }
    
    private func setupNotificationIndicator() {
        let indicator = CALayer()
        indicator.backgroundColor = NSColor.systemBlue.cgColor
        indicator.cornerRadius = 4
        indicator.isHidden = true
        layer?.addSublayer(indicator)
        notificationIndicator = indicator
    }
    
    private func observeNotificationState() {
        if ZenithState.shared.notificationPulseEnabled {
            NotificationMonitor.shared.setEnabled(true)
        }
        NotificationMonitor.shared.$hasUnreadNotifications
            .receive(on: RunLoop.main)
            .sink { [weak self] hasNotifications in
                self?.updateNotificationIndicator(hasNotifications: hasNotifications)
            }
            .store(in: &cancellables)
    }
    
    private func updateNotificationIndicator(hasNotifications: Bool) {
        guard ZenithState.shared.notificationPulseEnabled else {
            notificationIndicator?.isHidden = true
            stopPulseAnimation()
            return
        }
        
        notificationIndicator?.isHidden = !hasNotifications
        
        if hasNotifications {
            startBreathingAnimation()
        } else {
            stopPulseAnimation()
        }
    }
    
    private func startBreathingAnimation() {
        guard notificationIndicator?.animation(forKey: "breathingPulse") == nil else { return }
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.3
        pulseAnimation.duration = 1.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        notificationIndicator?.add(pulseAnimation, forKey: "breathingPulse")
    }
    
    private func stopPulseAnimation() {
        notificationIndicator?.removeAnimation(forKey: "breathingPulse")
    }
    
    override func layout() {
        super.layout()
        
        if let button = aiButton {
            let buttonSize: CGFloat = 20
            button.frame = NSRect(
                x: bounds.width - buttonSize - 8,
                y: (bounds.height - buttonSize) / 2,
                width: buttonSize,
                height: buttonSize
            )
        }
        
        if let indicator = notificationIndicator {
            let indicatorSize: CGFloat = 8
            indicator.frame = NSRect(
                x: bounds.width - indicatorSize - 8 - 20 - 6,
                y: (bounds.height - indicatorSize) / 2,
                width: indicatorSize,
                height: indicatorSize
            )
        }
    }
    
    @objc private func openAIQuery() {
        let mouseLocation = NSEvent.mouseLocation
        AIQueryWindow.shared.show(at: CGPoint(x: mouseLocation.x - 200, y: mouseLocation.y - 220))
    }
    
    func updateAppearance() {
        // Solid rounded bar - subtle for stencil effect
        let opacity = CGFloat(ZenithState.shared.barOpacity)
        let color = NSColor.white.withAlphaComponent(opacity)
        
        // Rounded rectangle with fully rounded ends
        let radius = bounds.height / 2
        layer?.cornerRadius = max(1, radius)
        layer?.backgroundColor = color.cgColor
        
        // Subtle border
        layer?.borderColor = NSColor.white.withAlphaComponent(opacity * 0.5).cgColor
        layer?.borderWidth = 1
        
        // Minimal shadow
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.2
        layer?.shadowRadius = 3
        layer?.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    private func setupTrackingArea() {
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: superview,
            userInfo: nil
        )
        trackingArea = area
        addTrackingArea(area)
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.notchClicked()
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

protocol NotchClickAreaDelegate: AnyObject {
    func notchClicked()
}

// MARK: - DockIconView
// Individual icon button
class DockIconView: NSView {
    weak var delegate: DockIconViewDelegate?
    private var button: DockButton?
    private var iconLayer: CATextLayer!
    private var artworkLayer: CALayer!
    private var isHovered = false
    private var trackingArea: NSTrackingArea?
    private var isMusicButton = false
    private var displayArtwork = false
    private var cancellables = Set<AnyCancellable>()
    private var quickActionsPanel: QuickActionsPanel?
    private var quickActionTimer: Timer?
    private var lastClickTime: Date?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
        setupTracking()
        observeMusic()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupTracking()
        observeMusic()
    }
    
    private func setupLayers() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        artworkLayer = CALayer()
        artworkLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        artworkLayer.isHidden = true
        artworkLayer.cornerRadius = 6
        artworkLayer.masksToBounds = true
        layer?.addSublayer(artworkLayer)
        
        iconLayer = CATextLayer()
        iconLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        iconLayer.alignmentMode = .center
        iconLayer.isWrapped = true
        layer?.addSublayer(iconLayer)
    }
    
    private func observeMusic() {
        MusicController.shared.$currentTrack
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                self?.updateArtwork(with: track)
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            MusicController.shared.initialize()
        }
    }
    
    private func updateArtwork(with track: MusicTrackInfo?) {
        guard isMusicButton, displayArtwork else { return }
        
        if let track = track, let artwork = track.artwork {
            artworkLayer.contents = artwork
            artworkLayer.isHidden = false
            iconLayer.isHidden = true
        } else {
            artworkLayer.isHidden = true
            iconLayer.isHidden = false
        }
    }
    
    private func setupTracking() {
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        setupTracking()
    }
    
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    
    func configure(with button: DockButton, state: ZenithState, iconIndex: Int = 0) {
        self.button = button
        
        isMusicButton = button.actionType == .music
        displayArtwork = isMusicButton && ZenithState.shared.musicDisplayMode == .artwork
        
        let accentColors: [String: String] = [
            "white": "#FFFFFF",
            "blue": "#007AFF",
            "purple": "#AF52DE",
            "pink": "#FF2D55",
            "orange": "#FF9500",
            "green": "#34C759"
        ]
        let hexValue = accentColors[state.accentColor.rawValue] ?? "#FFFFFF"
        let accentColor = NSColor(hex: hexValue) ?? .white
        
        let size = CGFloat(state.iconSize)
        let fontSize = size * 0.47
        
        iconLayer.string = button.icon
        iconLayer.fontSize = fontSize
        if let font = NSFont.systemFont(ofSize: fontSize, weight: .medium) as CTFont? {
            iconLayer.font = font
        }
        
        switch state.dockStyle {
        case .normal:
            iconLayer.foregroundColor = accentColor.cgColor
            layer?.shadowOpacity = 0
            
        case .minimal:
            let outlineColor: NSColor = state.useWhiteOutline ? .white : accentColor
            iconLayer.foregroundColor = outlineColor.cgColor
            layer?.shadowOpacity = 0.2
            layer?.shadowColor = outlineColor.cgColor
            layer?.shadowRadius = 2
            
        case .bold:
            iconLayer.foregroundColor = accentColor.cgColor
            layer?.shadowOpacity = 0.6
            layer?.shadowColor = accentColor.cgColor
            layer?.shadowRadius = state.borderWidth * 2
            
        case .glow:
            iconLayer.foregroundColor = accentColor.cgColor
            layer?.shadowOpacity = 0.8
            layer?.shadowColor = accentColor.cgColor
            layer?.shadowRadius = 10
        }
        
        artworkLayer.frame = bounds.insetBy(dx: 2, dy: 2)
        iconLayer.frame = bounds
        
        if displayArtwork {
            updateArtwork(with: MusicController.shared.currentTrack)
        }
    }
    
    override func layout() {
        super.layout()
        artworkLayer.frame = bounds.insetBy(dx: 2, dy: 2)
        iconLayer.frame = bounds
    }
    
    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        
        let state = ZenithState.shared
        if state.useSpringAnimations {
            SpringAnimator.animateSpringScale(
                layer: layer!,
                to: 1.2,
                stiffness: state.springStiffness,
                damping: state.springDamping
            )
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().layer?.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            }
        }
        
        if ZenithState.shared.hapticFeedback {
            NSFeedbackHelper().lightTap()
        }
        
        handleHoverStart()
    }
    
    override func mouseExited(with event: NSEvent) {
        isHovered = false
        
        let state = ZenithState.shared
        if state.useSpringAnimations {
            SpringAnimator.animateSpringScale(
                layer: layer!,
                to: 1.0,
                stiffness: state.springStiffness,
                damping: state.springDamping
            )
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                self.animator().layer?.transform = CATransform3DIdentity
            }
        }
        
        handleHoverEnd()
    }
    
    override func mouseDown(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.05
            self.animator().layer?.transform = CATransform3DMakeScale(0.9, 0.9, 1.0)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let targetScale: CGFloat = isHovered ? 1.2 : 1.0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.08
            self.animator().layer?.transform = CATransform3DMakeScale(targetScale, targetScale, 1.0)
        }
        
        handleClick()
    }
    
    private func handleHoverStart() {
        guard let button = button, button.quickActionsEnabled else { return }
        guard button.quickActionTrigger == .hover else { return }
        
        quickActionTimer?.invalidate()
        quickActionTimer = Timer.scheduledTimer(withTimeInterval: button.quickActionDelay, repeats: false) { [weak self] _ in
            self?.showQuickActions()
        }
    }
    
    private func handleHoverEnd() {
        quickActionTimer?.invalidate()
        quickActionTimer = nil
        
        if quickActionsPanel == nil {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if !self.quickActionsPanel!.frame.contains(NSEvent.mouseLocation) {
                self.dismissQuickActions()
            }
        }
    }
    
    private func handleClick() {
        guard let button = button else { return }
        
        if button.quickActionsEnabled && button.quickActionTrigger == .doubleClick {
            let now = Date()
            if let lastClick = lastClickTime, now.timeIntervalSince(lastClick) < 0.3 {
                showQuickActions()
                lastClickTime = nil
                return
            }
            lastClickTime = now
        }
        
        delegate?.iconClicked(self, button: button)
    }
    
    private func showQuickActions() {
        guard let button = button else { return }
        
        let actions = QuickActionsManager.shared.getQuickActions(for: button)
        guard !actions.isEmpty else { return }
        
        dismissQuickActions()
        
        quickActionsPanel = QuickActionsPanel(actions: actions) { [weak self] actionType in
            QuickActionsManager.shared.executeAction(actionType)
            self?.dismissQuickActions()
        } onDismiss: { [weak self] in
            self?.dismissQuickActions()
        }
        
        guard let panel = quickActionsPanel else { return }
        
        let anchorRect = self.convert(self.bounds, to: nil)
        panel.displayAt(anchorRect: anchorRect)
    }
    
    private func dismissQuickActions() {
        quickActionsPanel?.close()
        quickActionsPanel = nil
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

protocol DockIconViewDelegate: AnyObject {
    func iconClicked(_ icon: DockIconView, button: DockButton)
}

extension NSColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
