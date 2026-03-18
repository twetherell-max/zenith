import AppKit
import SwiftUI
import WebKit

class RadialDockContainerView: NSView {
    weak var webView: WKWebView?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        webView?.evaluateJavaScript("setExpanded(true)") { _, _ in }
    }
    
    override func mouseExited(with event: NSEvent) {
        webView?.evaluateJavaScript("setExpanded(false)") { _, _ in }
    }
}

class RadialDockCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    
    override init() {
        super.init()
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "radialDock",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }
        
        if type == "iconClick", let idString = body["id"] as? String, let uuid = UUID(uuidString: idString) {
            if let segment = ZenithState.shared.findSegment(by: uuid) {
                ZenithState.shared.executeAction(for: segment)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    
    var statusItem: NSStatusItem?
    var zenithWindow: ZenithWindow?
    var settingsWindow: NSWindow?
    
    // Explicit access to state for injection
    let state = ZenithState.shared

    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // THE SHARED LINK - ABSOLUTE FIRST LINE
        AppDelegate.shared = self
        
        // Safety: ensure activation policy is correct
        NSApp.setActivationPolicy(.regular)
        
        // Kill ghosts
        NSApp.disableRelaunchOnLogin()
        
        // FORCE MENU BAR
        setupStatusItem()

        if self.zenithWindow == nil {
            print(">>> Creating Zenith Window...")
            
            let screen = NotchManager.shared.findBuiltInScreen() ?? NSScreen.main ?? NSScreen.screens[0]
            let screenWidth = screen.frame.width
            let safeTop = screen.safeAreaInsets.top
            let notchFrame = NotchManager.shared.notchFrame
            
            print(">>> Screen: \(screenWidth), safeTop: \(safeTop)")
            print(">>> Notch: \(notchFrame)")
            print(">>> Visible frame: \(screen.visibleFrame)")
            
            // Use a compact top-floating window so it sits high under menu bar
            let windowHeight: CGFloat = 260
            let windowWidth: CGFloat = 420

            // Position at the highest top (under menu bar)
            let topMargin: CGFloat = 8
            let windowY = screen.frame.height - windowHeight - topMargin
            let windowX = (screen.frame.width - windowWidth) / 2

            print(">>> Window X: \(windowX), Y: \(windowY)")

            let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)
            
            let window = NSWindow(
                contentRect: windowFrame,
                styleMask: NSWindow.StyleMask.borderless,
                backing: NSWindow.BackingStoreType.buffered,
                defer: false
            )
            
            window.backgroundColor = NSColor.clear
            window.isOpaque = false
            window.ignoresMouseEvents = false
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
            window.collectionBehavior = NSWindow.CollectionBehavior([.canJoinAllSpaces, .fullScreenAuxiliary, .stationary])
            window.hasShadow = false
            window.isRestorable = false
            window.isReleasedWhenClosed = false
            
            print(">>> Window frame: \(window.frame)")
            print(">>> Screen: \(screen.frame)")
            
            // Create WebView container
            let containerView = NSView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
            containerView.wantsLayer = true
            
            // Create WKWebView directly
            let config = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            let coordinator = RadialDockCoordinator()
            userContentController.add(coordinator, name: "radialDock")
            config.userContentController = userContentController
            
            let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight), configuration: config)
            webView.navigationDelegate = coordinator
            webView.setValue(false, forKey: "drawsBackground")
            webView.autoresizingMask = [.width, .height]
            coordinator.webView = webView
            
            // Add tracking area for mouse movement
            let trackingArea = NSTrackingArea(
                rect: containerView.bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: containerView,
                userInfo: nil
            )
            containerView.addTrackingArea(trackingArea)
            
            // Load HTML from bundle (try main bundle first, then module bundle)
            if let htmlURL = Bundle.main.url(forResource: "radial-dock", withExtension: "html") {
                print(">>> Loading HTML from main bundle: \(htmlURL.path)")
                webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
            } else if let htmlURL = Bundle(for: type(of: self)).url(forResource: "radial-dock", withExtension: "html") {
                print(">>> Loading HTML from module bundle: \(htmlURL.path)")
                webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
            } else {
                print(">>> HTML file not found")
                if let resourceURL = Bundle.main.resourceURL {
                    print(">>> Main resource URL: \(resourceURL.path)")
                }
                print(">>> Bundle identifier: \(Bundle.main.bundleIdentifier ?? "nil")")
            }
            
            containerView.addSubview(webView)
            window.contentView = containerView
            
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil as Any?)
            
            print(">>> Window created and ordered front")
            
            self.zenithWindow = window as? ZenithWindow
        }
        
        ShortcutManager.shared.startMonitoring { [weak self] type in
            if type == .pulse {
                DispatchQueue.main.async {
                    self?.zenithWindow?.pulse()
                }
            }
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Zenith")
            button.action = #selector(showSettingsWindow)
            button.target = self
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    @objc func showSettingsWindow() {
        print("DEBUG: Gear Clicked")
        print(">>> Attempting to open STYLED settings window...")
        
        // UNIFIED STATE SYNC
        ZenithState.shared.isSettingsOpen = true
        ZenithState.shared.isExpanded = true
        
        if settingsWindow == nil {
            print(">>> CREATING STYLED NSWindow + VIEW INJECTION...")
            
            let settingsView = ZenithSettingsView()
            let hostingView = NSHostingView(rootView: settingsView)
            
            // GOOD WINDOW MASK
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            window.contentView = hostingView
            window.title = "Zenith Settings"
            window.isReleasedWhenClosed = false
            window.isRestorable = false
            
            // BOSS POSITIONING & LEVEL
            window.center()
            window.level = .floating 
            
            self.settingsWindow = window
            
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: settingsWindow, queue: .main) { [weak self] _ in
                print(">>> STYLED SETTINGS CLOSING...")
                ZenithState.shared.isSettingsOpen = false
                ZenithState.shared.isExpanded = false
                self?.settingsWindow = nil
            }
        }
        
        // THE BOSS ACTIVATION
        self.settingsWindow?.makeKeyAndOrderFront(nil)
        self.settingsWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
