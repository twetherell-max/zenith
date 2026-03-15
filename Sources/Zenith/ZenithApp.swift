import SwiftUI
import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    var zenithWindow: ZenithWindow?
    var settingsWindow: NSWindow?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // FORCE EARLY INIT
        AppDelegate.shared = self
        
        // KILL GHOSTS
        NSApp.disableRelaunchOnLogin()
        
        setupStatusItem()

        // GLOBAL VISIBILITY
        NSApp.setActivationPolicy(.regular)
        
        // STARTUP REIFICATION
        if self.zenithWindow == nil {
            let builtInScreen = NotchManager.shared.findBuiltInScreen()
            let notchFrame = NotchManager.shared.notchFrame
            
            let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
            window.title = "ZenithWindow"
            
            // GHOST MODE SYSTEM
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.isRestorable = false 
            window.ignoresMouseEvents = false
            
            // FORCE VISIBILITY COMMANDS
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            
            self.zenithWindow = window
        }
        
        ShortcutManager.shared.startMonitoring { [weak self] type in
            switch type {
            case .toggle:
                print("Shortcut: Toggle")
            case .pulse:
                DispatchQueue.main.async {
                    self?.zenithWindow?.pulse()
                }
            }
        }
        
        setupMenu()
    }
    
    private func setupMenu() {
        let mainMenu = NSMenu()
        let appMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ","))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.hexagonpath", accessibilityDescription: nil)
            button.action = #selector(showSettingsWindow)
            button.target = self
        }
    }
    
    @objc func showSettingsWindow() {
        ZenithState.shared.isSettingsOpen = true
        ZenithState.shared.isExpanded = true
        
        if settingsWindow == nil {
            settingsWindow = ZenithSettingsWindow()
            settingsWindow?.isRestorable = false
            
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: settingsWindow, queue: .main) { [weak self] _ in
                ZenithState.shared.isSettingsOpen = false
                ZenithState.shared.isExpanded = false
                self?.settingsWindow = nil
            }
        }
        
        NSApp.activate(ignoringOtherApps: true)
        self.settingsWindow?.makeKeyAndOrderFront(nil)
        self.settingsWindow?.orderFrontRegardless()
        settingsWindow?.center()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
