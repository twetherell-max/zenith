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
        print("WINDOW SETUP STARTED")
        
        // Force Foreground Mode (Dock icon visible)
        NSApp.setActivationPolicy(.regular)
        
        let builtInScreen = NotchManager.shared.findBuiltInScreen()
        let notchFrame = NotchManager.shared.notchFrame
        
        // Initialize window and store in strong property
        let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
        self.zenithWindow = window
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print(">>> SYSTEM: Zenith window is now initialized. Check your screens. <<<")
        
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
