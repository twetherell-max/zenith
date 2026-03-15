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
        
        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 400)
        self.contentView = hostingView
        self.delegate = self
    }
}

struct SettingsView: View {
    @ObservedObject var state = ZenithState.shared
    
    @AppStorage("isDarkGlass") private var isDarkGlass: Bool = false
    
    var body: some View {
        let _ = print("Spread value: \(state.arcSpread)")
        
        return VStack(spacing: 0) {
            // BLUE VISUAL ANCHOR (IF THIS IS GONE, SWIFTUI IS DEAD)
            Color.blue
                .frame(height: 20)
                .overlay(
                    HStack {
                        Text("ZENITH SETTINGS").font(.caption2).bold()
                        Spacer()
                        Text("BRAIN ID: \(state.debugID)").font(.system(size: 8, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                )
            
            VStack(spacing: 20) {
                Form {
                    Section {
                        Toggle("High Contrast (Dark Glass)", isOn: $isDarkGlass)
                    }
                
                    Section(header: Text("Geometry").font(.caption).foregroundColor(.secondary)) {
                        VStack(alignment: .leading) {
                            Text("Arc Spread: \(Int(state.arcSpread))px")
                            Slider(value: $state.arcSpread, in: 20...150, step: 1.0)
                                .id(state.arcSpread)
                                .onChange(of: state.arcSpread) { val in print("New Spread: \(val)") }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Drop Depth: \(Int(state.dropDepth))px")
                            Slider(value: $state.dropDepth, in: 10...100, step: 1.0)
                                .onChange(of: state.dropDepth) { val in print("New Depth: \(val)") }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Icon Size: \(Int(state.iconSize))pt")
                            Slider(value: $state.iconSize, in: 10...25, step: 1.0)
                                .onChange(of: state.iconSize) { val in print("New Size: \(val)") }
                        }
                    }
                }
                .formStyle(.grouped)
                // MASTER MONITOR: Double-wire the data flow output to terminal
                .onChange(of: state.arcSpread) { _ in
                    print("GLOBAL SPREAD UPDATED: \(state.arcSpread)")
                }
                .onChange(of: state.arcSpread) { newValue in
                    print(">>> LIVE ARC SPREAD: \(newValue)")
                }
                
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
