import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
    static var shared: ZenithSettingsWindow?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Zenith Settings"
        self.isReleasedWhenClosed = false
        self.backgroundColor = .windowBackgroundColor
        
        let settingsView = SettingsView(state: ZenithState.shared)
        self.contentView = NSHostingView(rootView: settingsView)
        self.delegate = self
    }
    
    static func show() {
        // ENSURE APP PROMOTION
        NSApp.setActivationPolicy(.regular)
        
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        
        guard let window = shared else { return }
        
        // RE-ATTACH VIEW (ENSURE FRESH STATE BRIDGE)
        window.contentView = NSHostingView(rootView: SettingsView(state: ZenithState.shared))
        
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        ZenithSettingsWindow.shared = nil
    }
}

struct SettingsView: View {
    @ObservedObject var state: ZenithState
    
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Zenith Settings")
                .font(.headline)
            
            Form {
                Section {
                    Toggle("High Contrast (Dark Glass)", isOn: $isDarkGlass)
                }
            
                Section(header: Text("Geometry").font(.caption).foregroundColor(.secondary)) {
                    VStack(alignment: .leading) {
                        Text("Arc Spread: \(Int(state.arcSpread))px")
                        Slider(value: $state.arcSpread, in: 20...150, step: 1.0)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Drop Depth: \(Int(state.dropDepth))px")
                        Slider(value: $state.dropDepth, in: 10...100, step: 1.0)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Icon Size: \(Int(state.iconSize))pt")
                        Slider(value: $state.iconSize, in: 10...25, step: 1.0)
                    }
                }
            }
            .formStyle(.grouped)
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 10)
        }
        .padding()
        .frame(width: 400, height: 450)
    }
}
