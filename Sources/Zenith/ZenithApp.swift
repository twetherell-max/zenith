import SwiftUI
import AppKit

struct ZenithApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Color.clear
                .frame(width: 0, height: 0)
                .hidden()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    var zenithWindow: ZenithWindow?
    var settingsWindow: NSWindow?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        
        setupStatusItem()
        // 0. PROCESS TERMINATION: Kill other running instances of Zenith
        let runningApps = NSWorkspace.shared.runningApplications
        let currentApp = NSRunningApplication.current
        for app in runningApps {
            if app.bundleIdentifier == currentApp.bundleIdentifier && app != currentApp {
                print(">>> STARTUP: Terminating existing Zenith process...")
                app.terminate()
            }
        }

        // 1. ZOMBIE PURGE: Kill any existing windows by title to clear remnants
        NSApp.windows.forEach { window in
            if window.title == "ZenithWindow" || window.title == "Zenith Settings" {
                print(">>> STARTUP PURGE: Closing zombie window...")
                window.close()
            }
        }

        // 1. GLOBAL VISIBILITY: Show in Dock and App Switcher
        NSApp.setActivationPolicy(.regular)
        
        // 2. MENU BAR SETUP
        setupMenu()
        
        // 3. SINGLETON CHECK: Only create window if it doesn't exist
        if self.zenithWindow == nil {
            let builtInScreen = NotchManager.shared.findBuiltInScreen()
            let notchFrame = NotchManager.shared.notchFrame
            
            let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
            window.title = "ZenithWindow"
            
            // GHOST MODE: ABSOLUTE TRANSPARENCY
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = false
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
            window.contentView?.layer?.isGeometryFlipped = false
            
            self.zenithWindow = window
        }
        
        ShortcutManager.shared.startMonitoring { [weak self] type in
            switch type {
            case .toggle:
                print("Shortcut triggered: Toggle")
            case .pulse:
                print("Shortcut triggered: Pulse")
                DispatchQueue.main.async {
                    self?.zenithWindow?.pulse()
                }
            }
        }
    }
    
    private func setupMenu() {
        let mainMenu = NSMenu()
        
        let appMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        
        // SETTINGS (Cmd+,)
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openCustomSettings), keyEquivalent: ",")
        appMenu.addItem(settingsItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        // QUIT (Cmd+Q)
        let quitItem = NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitItem)
        
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.hexagonpath", accessibilityDescription: nil)
            button.action = #selector(openCustomSettings)
            button.target = self
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openCustomSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    @objc func openCustomSettings() {
        // ENFORCE SINGLE BRAIN UNIFICATION
        ZenithState.shared.isSettingsOpen = true
        ZenithState.shared.isExpanded = true
        
        if settingsWindow == nil {
            print(">>> CREATING UNIFIED SETTINGS WINDOW")
            settingsWindow = ZenithSettingsWindow()
            
            // Register closure cleanup
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: settingsWindow, queue: .main) { [weak self] _ in
                print(">>> UNIFIED SETTINGS CLOSING | Cleaning flags")
                ZenithState.shared.isSettingsOpen = false
                ZenithState.shared.isExpanded = false
                self?.settingsWindow = nil
            }
        }
        
        print(">>> ACTIVATING UNIFIED SETTINGS")
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
        settingsWindow?.center()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
