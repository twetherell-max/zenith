import AppKit
import Combine

class NotchWindowManager: NSObject {
    static let shared = NotchWindowManager()
    
    private var notchWindows: [NSScreen: NSWindow] = [:]
    private var edgeToEdgeWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var screenChangeMonitor: Any?
    
    override init() {
        super.init()
        setupNotchWindows()
        observeStateChanges()
        observeScreenChanges()
    }
    
    private func observeScreenChanges() {
        // Listen for screen changes (connect/disconnect monitors)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func screensDidChange() {
        print(">>> Screens changed, rebuilding notch windows")
        tearDownAllWindows()
        setupNotchWindows()
    }
    
    private func setupNotchWindows() {
        let state = ZenithState.shared
        let screens = state.enableMultiMonitor ? NSScreen.screens : [NSScreen.main ?? NSScreen.screens[0]]
        
        for screen in screens {
            createNotchWindow(for: screen)
        }
    }
    
    private func createNotchWindow(for screen: NSScreen) {
        let state = ZenithState.shared
        let notchFrame = calculateNotchFrame(for: screen)
        
        let window = NSWindow(
            contentRect: notchFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .statusBar
        window.hasShadow = false
        window.title = "Zenith Notch - \(screen.localizedName)"
        window.isRestorable = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = true
        
        // Create notch view based on render mode
        let rootView: AnyView
        switch state.notchRenderMode {
        case .notchOnly:
            rootView = AnyView(NotchOnlyView())
        case .edgeToEdge:
            rootView = AnyView(EdgeToEdgeView())
        case .hiddenNotch:
            window.isHidden = true
            rootView = AnyView(EmptyView())
        }
        
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = notchFrame
        
        window.contentView = hostingView
        window.orderFrontRegardless()
        
        notchWindows[screen] = window
    }
    
    private func calculateNotchFrame(for screen: NSScreen) -> CGRect {
        let screenFrame = screen.frame
        let state = ZenithState.shared
        let notchWidth = state.notchWidth
        let notchHeight = state.notchHeight
        
        let x = (screenFrame.width - notchWidth) / 2
        let y = screenFrame.height - notchHeight - 10
        
        return CGRect(x: x, y: y, width: notchWidth, height: notchHeight + 5)
    }
    
    private func observeStateChanges() {
        // Listen for render mode changes
        ZenithState.shared.$notchRenderMode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tearDownAllWindows()
                self?.setupNotchWindows()
            }
            .store(in: &cancellables)
        
        ZenithState.shared.$enableMultiMonitor
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tearDownAllWindows()
                self?.setupNotchWindows()
            }
            .store(in: &cancellables)
        
        ZenithState.shared.$notchWidth
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAllWindowFrames()
            }
            .store(in: &cancellables)
        
        ZenithState.shared.$notchHeight
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAllWindowFrames()
            }
            .store(in: &cancellables)
    }
    
    private func updateAllWindowFrames() {
        for (screen, window) in notchWindows {
            let newFrame = calculateNotchFrame(for: screen)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = ZenithState.shared.notchAnimationDuration
                window.animator().setFrame(newFrame, display: true)
            }
        }
    }
    
    private func tearDownAllWindows() {
        for (_, window) in notchWindows {
            window.close()
        }
        notchWindows.removeAll()
        
        if let edgeWindow = edgeToEdgeWindow {
            edgeWindow.close()
            edgeToEdgeWindow = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        tearDownAllWindows()
    }
}

// MARK: - Render Mode Views

struct NotchOnlyView: View {
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
        ZStack {
            // Only the notch shape
            HStack(spacing: 0) {
                Spacer()
                
                UnevenRoundedRectangle(
                    topLeadingRadius: state.notchCornerRadius,
                    topTrailingRadius: state.notchCornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0
                )
                .fill(state.notchColor.color)
                .opacity(state.notchOpacity)
                .frame(width: state.notchWidth, height: state.notchHeight)
                
                Spacer()
            }
            .frame(height: state.notchHeight + 5)
            .padding(.top, 8)
        }
        .background(Color.clear)
    }
}

struct EdgeToEdgeView: View {
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
        VStack {
            // Full-width dark overlay at top
            Rectangle()
                .fill(state.notchColor.color)
                .opacity(state.edgeToEdgeOpacity)
                .frame(height: 50)
            
            Spacer()
        }
        .background(Color.clear)
    }
}
