import SwiftUI
import AppKit

struct ZenithApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var zenithWindow: ZenithWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
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
            if window.title == "ZenithWindow" {
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
            window.title = "ZenithWindow" // SET TITLE FOR PURGE IDENTIFICATION
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
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        appMenu.addItem(settingsItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        // QUIT (Cmd+Q)
        let quitItem = NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitItem)
        
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }
    
    @objc func openSettings() {
        ZenithState.shared.isSettingsOpen = true
        print("DEBUG: Settings is now true | \(ZenithState.shared.isSettingsOpen)")
        
        // Master Closure Observer: Reset state when the settings window is closed
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { notification in
            if let window = notification.object as? NSWindow, window.title == "Zenith Settings" {
                print("DEBUG: Settings Window Detected Closure | Resetting state")
                ZenithState.shared.isSettingsOpen = false
            }
        }
        
        NSApp.activate(ignoringOtherApps: true)
        ZenithSettingsWindow.show()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
