import SwiftUI
import AppKit

@main
struct ZenithApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    
    // STRONG PROPERTIES TO PREVENT DEALLOCATION
    var statusItem: NSStatusItem?
    var zenithWindow: ZenithWindow?
    var settingsWindow: NSWindow?

    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // THE HARD LINK - MUST BE THE ABSOLUTE FIRST LINE
        AppDelegate.shared = self
        
        // REGULAR MODE FOR DIAGNOSTIC VISIBILITY
        NSApp.setActivationPolicy(.regular)
        
        // Kill ghosts
        NSApp.disableRelaunchOnLogin()
        
        // FORCE MENU BAR
        setupStatusItem()

        if self.zenithWindow == nil {
            let builtInScreen = NotchManager.shared.findBuiltInScreen()
            let notchFrame = NotchManager.shared.notchFrame
            
            let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
            window.title = "ZenithWindow"
            
            // Visibility Boss Commands
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            
            self.zenithWindow = window
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
            // EXPLICIT ICON ENFORCEMENT
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
        print(">>> Attempting to open STYLED settings...")
        
        // UNIFIED STATE SYNC
        ZenithState.shared.isSettingsOpen = true
        ZenithState.shared.isExpanded = true
        
        if settingsWindow == nil {
            print(">>> CREATING STYLED NSWindow + NSHostingController...")
            
            let styledSettingsView = ZenithSettingsView()
            let hostingController = NSHostingController(rootView: styledSettingsView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window.contentViewController = hostingController
            window.title = "Zenith Settings"
            window.isReleasedWhenClosed = false
            window.isRestorable = false
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.backgroundColor = .clear 
            
            // BOSS POSITIONING
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
        NSApp.activate(ignoringOtherApps: true)
        self.settingsWindow?.makeKeyAndOrderFront(nil)
        self.settingsWindow?.orderFrontRegardless()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
