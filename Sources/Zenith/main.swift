import AppKit
import SwiftUI

autoreleasepool {
    let bundleID = Bundle.main.bundleIdentifier ?? "com.twetherell.zenith"
    let apps = NSWorkspace.shared.runningApplications.filter { 
        $0.bundleIdentifier == bundleID && $0 != NSRunningApplication.current 
    }
    
    if !apps.isEmpty {
        print(">>> SURGICAL GUARD: Terminating ghost Zenith instances...")
        for app in apps {
            app.terminate()
        }
    }
}

// HAND OFF TO SWIFTUI
ZenithApp.main()
