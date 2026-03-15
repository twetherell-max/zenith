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
                        Toggle("High Contrast (Dark Glass)", isOn: $state.isDarkGlass)
                            .contentShape(Rectangle())
                            .zIndex(100)
                    }
                
                    Section(header: Text("Geometry").font(.caption).foregroundColor(.secondary)) {
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Arc Spread: \(Int(state.arcSpread))px")
                                Slider(value: $state.arcSpread, in: 20...150, step: 1.0)
                                    .contentShape(Rectangle())
                                    .zIndex(100)
                                    .onChange(of: state.arcSpread) { val in print("New Spread: \(val)") }
                            }
                        }
                        .padding(2)
                        .zIndex(100)
                        
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Drop Depth: \(Int(state.dropDepth))px")
                                Slider(value: $state.dropDepth, in: 0...100, step: 1.0)
                                    .contentShape(Rectangle())
                                    .zIndex(100)
                                    .onChange(of: state.dropDepth) { val in print("New Depth: \(val)") }
                            }
                        }
                        .padding(2)
                        .zIndex(100)
                        
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Icon Size: \(Int(state.iconSize))pt")
                                Slider(value: $state.iconSize, in: 10...25, step: 1.0)
                                    .contentShape(Rectangle())
                                    .zIndex(100)
                                    .onChange(of: state.iconSize) { val in print("New Size: \(val)") }
                            }
                        }
                        .padding(2)
                        .zIndex(100)
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
