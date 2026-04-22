import AppKit
import Combine

class NotchWindowManager: NSObject {
    static let shared = NotchWindowManager()
    
    private var notchWindows: [NSScreen: NSWindow] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupNotchWindows()
        observeStateChanges()
    }
    
    private func setupNotchWindows() {
        let state = ZenithState.shared
        let screens = state.multiMonitorMode == .allMonitors ? NSScreen.screens : [NSScreen.main ?? NSScreen.screens[0]]
        
        for screen in screens {
            createNotchWindow(for: screen)
        }
    }
    
    private func createNotchWindow(for screen: NSScreen) {
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
        window.title = "Zenith Notch"
        window.isRestorable = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = true
        
        // Create notch view
        let rootView = MinimalNotchView()
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
        ZenithState.shared.$appMode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAllWindows()
            }
            .store(in: &cancellables)
        
        ZenithState.shared.$notchWidth
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAllWindows()
            }
            .store(in: &cancellables)
        
        ZenithState.shared.$notchHeight
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAllWindows()
            }
            .store(in: &cancellables)
    }
    
    private func updateAllWindows() {
        for (screen, window) in notchWindows {
            let newFrame = calculateNotchFrame(for: screen)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                window.animator().setFrame(newFrame, display: true)
            }
        }
    }
}
