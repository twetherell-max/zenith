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
        // Re-enable Background Mode (No Dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // Final Screen Info for terminal confirmation
        print("--- Final Notch Calibration ---")
        for screen in NSScreen.screens {
            print("Screen: \(screen.localizedName) Frame: \(screen.frame) SafeArea: \(screen.safeAreaInsets)")
        }
        print("-------------------------------")
        
        let builtInScreen = NotchManager.shared.findBuiltInScreen()
        let notchFrame = NotchManager.shared.notchFrame
        
        let window = ZenithWindow(notchFrame: notchFrame, targetScreen: builtInScreen)
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
