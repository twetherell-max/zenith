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
        
        // PREVENT TRANSPARENCY BUGS: FORCE OPAQUE WHITE
        self.isOpaque = true
        self.backgroundColor = .white
        
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.becomesKeyOnlyIfNeeded = false
        self.title = "Zenith Settings"
        self.isReleasedWhenClosed = false
        
        let settingsView = SettingsView()
            .environmentObject(ZenithState.shared)
            .frame(width: 400, height: 400) // FORCE CONTENT SIZE
            
        self.contentView = NSHostingView(rootView: settingsView)
        self.contentView?.frame = NSRect(x: 0, y: 0, width: 400, height: 400)
        self.delegate = self
    }
    
    static func show() {
        if shared == nil {
            shared = ZenithSettingsWindow()
        }
        
        // FORCE NUCLEAR ACTIVATION
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // FORCE POSITION
        shared?.setFrameOrigin(NSPoint(x: 500, y: 500))
        
        shared?.makeKeyAndOrderFront(nil)
        shared?.orderFrontRegardless()
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
    @EnvironmentObject var state: ZenithState
    
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
