import AppKit
import SwiftUI

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
            
            // Use notch frame directly to position window
            let windowHeight: CGFloat = 100
            
            // Position window so its TOP aligns with notch
            let windowY = notchFrame.minY
            
            print(">>> Window Y: \(windowY)")
            
            let windowFrame = NSRect(x: 0, y: windowY, width: screenWidth, height: windowHeight)
            
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
            
            // Add arc view - ensure it's added properly
            let arcView = ZenithArcView()
            let hostingView = NSHostingView(rootView: arcView)
            hostingView.frame = NSRect(x: 0, y: 0, width: screenWidth, height: windowHeight)
            hostingView.autoresizingMask = [.width]
            
            // Replace the content view with our hosting view directly
            window.contentView = hostingView
            
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
