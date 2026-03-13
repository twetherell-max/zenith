import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow {
    static var shared: ZenithSettingsWindow?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
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
    @AppStorage("theme") private var theme: String = "Light Glass"
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    
    var body: some View {
        Form {
            Section(header: Text("Appearance").font(.headline)) {
                Picker("Theme", selection: $theme) {
                    Text("Light Glass").tag("Light Glass")
                    Text("Dark Glass").tag("Dark Glass")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Arc Spread: \(Int(arcSpread))px")
                    Slider(value: $arcSpread, in: 50...150, step: 10)
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
