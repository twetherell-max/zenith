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
    var zenithWindow: ZenithWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
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

        // Re-enable Background Mode (No Dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // 2. SINGLETON CHECK: Only create window if it doesn't exist
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
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
