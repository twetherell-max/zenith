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
        self.isRestorable = false
        
        let settingsView = ZenithSettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 400)
        self.contentView = hostingView
        self.delegate = self
    }
}

struct ZenithSettingsView: View {
    var body: some View {
        let state = ZenithState.shared
        
        VStack(spacing: 0) {
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
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("High Contrast (Dark Glass)", isOn: Binding(
                    get: { state.isDarkGlass },
                    set: { newValue in
                        state.isDarkGlass = newValue
                    }
                ))
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Arc Spread: \(Int(state.arcSpread))")
                        .font(.caption)
                    Slider(
                        value: Binding(
                            get: { state.arcSpread },
                            set: { newValue in
                                state.arcSpread = newValue
                            }
                        ),
                        in: 20...150,
                        step: 1
                    )
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Drop Depth: \(Int(state.dropDepth))")
                        .font(.caption)
                    Slider(
                        value: Binding(
                            get: { state.dropDepth },
                            set: { newValue in
                                state.dropDepth = newValue
                            }
                        ),
                        in: 0...100,
                        step: 1
                    )
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Icon Size: \(Int(state.iconSize))")
                        .font(.caption)
                    Slider(
                        value: Binding(
                            get: { state.iconSize },
                            set: { newValue in
                                state.iconSize = newValue
                            }
                        ),
                        in: 10...25,
                        step: 1
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Close") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
                .padding(.bottom, 20)
            }
            .padding(.top, 16)
        }
        .frame(width: 300, height: 400)
    }
}
