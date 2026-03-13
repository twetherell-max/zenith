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
        
        // --- First Launch Debug ---
        for screen in NSScreen.screens {
            print("Screen: \(screen.localizedName) Frame: \(screen.frame) SafeArea: \(screen.safeAreaInsets)")
        }
        
        // Trigger Accessibility Permission Prompt
        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in }
        
        let builtInScreen = NotchManager.shared.findBuiltInScreen()
        let notchFrame = NotchManager.shared.notchFrame
        
        let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
        window.makeKeyAndOrderFront(nil)
        window.setIsVisible(true)
        
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
