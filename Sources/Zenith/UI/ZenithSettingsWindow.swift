import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
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
        self.delegate = self
    }
    
    static func show() {
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        shared?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    
    // WINDOW LIFECYCLE SYNC
    func windowDidBecomeKey(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: "isSettingsOpen")
    }
    
    func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(false, forKey: "isSettingsOpen")
        ZenithSettingsWindow.shared = nil // FREE MEMORY
    }
}

struct SettingsView: View {
    @AppStorage("arcSpread") private var arcSpread: Double = 100.0
    @AppStorage("iconSize") private var iconSize: Double = 14.0
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    @AppStorage("isSettingsOpen") private var isSettingsOpen: Bool = false
    
    var body: some View {
        VStack {
            Text("Settings Loaded")
                .font(.caption)
                .foregroundColor(.green)
                .padding(.top, 10)
            
            Form {
                Section(header: Text("Appearance").font(.headline)) {
                    Toggle("High Contrast (Dark Glass)", isOn: $isDarkGlass)
                        .padding(.vertical, 8)
                }
            
            Section(header: Text("Geometry").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Arc Spread: \(Int(arcSpread))px")
                    Slider(value: $arcSpread, in: 50...150, step: 1.0)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Icon Size: \(Int(iconSize))pt")
                    Slider(value: $iconSize, in: 10...25, step: 1.0)
                }
                .padding(.bottom, 8)
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
        .frame(width: 400, height: 400)
        
        Button("Close & Apply") {
            NSApp.keyWindow?.close()
        }
        .padding(.bottom, 20)
        }
    }
}
