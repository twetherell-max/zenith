import AppKit
import SwiftUI

class ZenithSettingsWindow: NSPanel, NSWindowDelegate {
    static var shared: ZenithSettingsWindow?
    
    init() {
        super.init(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 400),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        print(">>> SETTINGS PANEL LOADED | FRAME: \(self.frame)")
        
        // NUCLEAR VISIBILITY: ABOVE EVERYTHING (NOTCH, DOCK, MENU BAR)
        self.level = .screenSaver 
        self.isFloatingPanel = true
        
        // BACK TO SYSTEM COLORS: FIXES 'BLACK VOID' RENDERING BUG
        self.isOpaque = true
        self.backgroundColor = .windowBackgroundColor
        
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.becomesKeyOnlyIfNeeded = false
        self.title = "Zenith Settings"
        self.isReleasedWhenClosed = false
        
        let settingsView = SettingsView(state: ZenithState.shared)
            .frame(width: 400, height: 400) // FORCE CONTENT SIZE
            
        self.contentView = NSHostingView(rootView: settingsView)
        self.contentView?.frame = NSRect(x: 0, y: 0, width: 400, height: 400)
        self.delegate = self
    }
    
    static func show() {
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        
        guard let panel = shared else { return }
        
        // 1. REPAIR CONTENT: Explicitly host the SwiftUI view with direct injection
        let settingsView = SettingsView(state: ZenithState.shared)
        
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.translatesAutoresizingMaskIntoConstraints = true
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 400)
        
        panel.contentView = hostingView
        panel.setContentSize(NSSize(width: 400, height: 400))
        
        // 2. FORCE POSITION & REDRAW
        panel.setFrameOrigin(NSPoint(x: 500, y: 500))
        panel.display() // FORCE PIXEL DRAW
        
        // 3. FINAL ACTIVATION HEARTBEAT
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
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
    @ObservedObject var state: ZenithState
    
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    @AppStorage("isSettingsOpen") private var isSettingsOpen: Bool = false
    
    var body: some View {
        VStack {
            Text("HELLO WORLD")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            Text("Settings Loaded")
                .font(.caption)
                .foregroundColor(.green)
            
            Form {
                Section(header: Text("Appearance").font(.headline)) {
                    Toggle("High Contrast (Dark Glass)", isOn: $isDarkGlass)
                        .padding(.vertical, 8)
                }
            
            Section(header: Text("Geometry").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Arc Spread: \(Int(state.arcSpread))px")
                    Slider(value: $state.arcSpread, in: 20...150, step: 1.0)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Drop Depth: \(Int(state.dropDepth))px")
                    Slider(value: $state.dropDepth, in: 10...100, step: 1.0)
                }
                .padding(.bottom, 8)
                
                VStack(alignment: .leading) {
                    Text("Icon Size: \(Int(state.iconSize))pt")
                    Slider(value: $state.iconSize, in: 10...25, step: 1.0)
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
        .frame(width: 400, height: 450)
        
        Button("Close & Apply") {
            NSApp.keyWindow?.close()
        }
        .padding(.bottom, 20)
        }
    }
}
