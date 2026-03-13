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
        NSApp.setActivationPolicy(.accessory)
        
        let notchFrame = NotchManager.shared.notchFrame
        if notchFrame != .zero {
            let window = ZenithWindow(notchFrame: notchFrame)
            window.makeKeyAndOrderFront(nil)
            self.zenithWindow = window
        }
    }
}
