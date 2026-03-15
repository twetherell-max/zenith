import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
    static var shared: ZenithSettingsWindow?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Zenith Settings"
        self.isReleasedWhenClosed = false
        self.backgroundColor = .windowBackgroundColor
        self.isOpaque = true
        self.hasShadow = true
        
        let settingsView = SettingsView(state: ZenithState.shared)
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 400)
        self.contentView = hostingView
        self.delegate = self
    }
    
    static func show() {
        // ENSURE APP PROMOTION
        NSApp.setActivationPolicy(.regular)
        
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        
        guard let window = shared else { return }
        
        // DIRECT VIEW HOSTING: Bypass controller complexity for stability
        let settingsView = SettingsView(state: ZenithState.shared)
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 400)
        
        window.contentView = hostingView
        window.backgroundColor = .windowBackgroundColor
        window.isOpaque = true
        
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        ZenithState.shared.isSettingsOpen = false
        ZenithSettingsWindow.shared = nil
    }
}

struct SettingsView: View {
    @ObservedObject var state: ZenithState
    
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // BLUE VISUAL ANCHOR (IF THIS IS GONE, SWIFTUI IS DEAD)
            Color.blue
                .frame(height: 20)
                .overlay(Text("ZENITH SETTINGS").font(.caption2).bold().foregroundColor(.white))
            
            VStack(spacing: 20) {
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
                .padding(.bottom, 20)
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}
