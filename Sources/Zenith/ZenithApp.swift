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
        // Force Foreground Mode (Dock icon visible)
        NSApp.setActivationPolicy(.regular)
        
        // --- Hard Diagnostic Alert ---
        let alert = NSAlert()
        alert.messageText = "Zenith is Alive!"
        alert.informativeText = "If you see this, the app started successfully."
        alert.addButton(withTitle: "OK")
        alert.runModal()
        // -----------------------------

        // Where Am I? Log
        print("DEBUG: Application started. Main screen resolution: \(NSScreen.main?.frame ?? .zero)")
        
        // Print All Screen Info
        print("--- Connected Screens ---")
        for screen in NSScreen.screens {
            print("Screen: \(screen.localizedName) Frame: \(screen.frame) VisibleFrame: \(screen.visibleFrame) SafeArea: \(screen.safeAreaInsets)")
        }
        print("-------------------------")
        
        let builtInScreen = NotchManager.shared.findBuiltInScreen()
        let notchFrame = NotchManager.shared.notchFrame
        // Unconditional creation for debugging
        let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
        window.makeKeyAndOrderFront(nil)
        self.zenithWindow = window
        
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
