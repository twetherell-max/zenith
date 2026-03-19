import SwiftUI
import AppKit

@main
struct ZenithApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            ZenithSettingsView()
                .frame(minWidth: 450, minHeight: 600)
        }
    }
}
