import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow {
    static var shared: ZenithSettingsWindow?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Zenith Settings"
        self.center()
        self.setFrameAutosaveName("ZenithSettingsWindow")
        self.isReleasedWhenClosed = false
        
        let settingsView = SettingsView()
        self.contentView = NSHostingView(rootView: settingsView)
    }
    
    static func show() {
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        shared?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("arcIntensity") private var arcIntensity: Double = 50.0
    
    var body: some View {
        Form {
            Section(header: Text("General").font(.headline)) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Slider(value: $arcIntensity, in: 10...100, label: { Text("Arc Curve") })
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("About").font(.headline)) {
                HStack {
                    Text("Zenith Version 1.0.0")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Check for Updates") {
                        print("Checking for updates...")
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .frame(width: 400, height: 300)
    }
}
