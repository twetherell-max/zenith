import AppKit
import SwiftUI

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
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
        
        // KILL GHOSTS: Explicitly disable restoration
        self.isRestorable = false
        
        // Pass the singleton state explicitly as requested
        let settingsView = ZenithSettingsView(state: ZenithState.shared)
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 400)
        self.contentView = hostingView
        self.delegate = self
    }
}

struct ZenithSettingsView: View {
    // ALLOW STATE INJECTION
    @ObservedObject var state: ZenithState
    
    var body: some View {
        VStack(spacing: 0) {
            // PRODUCTION HEADER
            VStack(spacing: 4) {
                HStack {
                    Text("ZENITH").font(.system(size: 10, weight: .black))
                    Spacer()
                    Text("BRAIN ID: \(state.debugID)").font(.system(size: 8, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Divider()
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            VStack(spacing: 20) {
                Form {
                    Section {
                        Toggle("High Contrast (Dark Glass)", isOn: $state.isDarkGlass)
                            .contentShape(Rectangle())
                    }
                
                    Section(header: Text("Geometry").font(.caption).foregroundColor(.secondary)) {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading) {
                                Text("Arc Spread: \(Int(state.arcSpread))px")
                                Slider(value: $state.arcSpread, in: 20...150, step: 1.0)
                                    .onChange(of: state.arcSpread) { oldValue, newValue in
                                        print("New Spread: \(newValue)")
                                    }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Drop Depth: \(Int(state.dropDepth))px")
                                Slider(value: $state.dropDepth, in: 0...100, step: 1.0)
                                    .onChange(of: state.dropDepth) { oldValue, newValue in
                                        print("New Depth: \(newValue)")
                                    }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Icon Size: \(Int(state.iconSize))pt")
                                Slider(value: $state.iconSize, in: 10...25, step: 1.0)
                                    .onChange(of: state.iconSize) { oldValue, newValue in
                                        print("New Size: \(newValue)")
                                    }
                            }
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
