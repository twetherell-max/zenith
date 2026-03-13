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
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as background agent (LSUIElement = 1)
        // Note: For Swift Packages, this is often handled by the host app or custom Info.plist,
        // but can be set programmatically or via target properties in Xcode.
        // Programmatic way to ensure it doesn't show in Dock:
        NSApp.setActivationPolicy(.accessory)
    }
}
