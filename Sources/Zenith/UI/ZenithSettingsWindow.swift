import AppKit
import SwiftUI

struct DockButtonEditor: View {
    @Binding var button: DockButton
    let onDelete: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(button.icon)
                    .font(.title)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    TextField("Title", text: $button.title)
                        .textFieldStyle(.roundedBorder)
                    
                    Text(button.actionType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $button.isEnabled)
                    .labelsHidden()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            if isExpanded {
                Divider()
                
                HStack {
                    Text("Action:")
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                    
                    Picker("", selection: $button.actionType) {
                        ForEach(DockButton.ActionType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if button.actionType == .music {
                    HStack {
                        Text("Control:")
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        Picker("", selection: $button.actionValue) {
                            ForEach(DockButton.MusicAction.allCases, id: \.self) { action in
                                Label(action.displayName, systemImage: action.icon).tag(action.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } else if button.actionType == .icon {
                    HStack {
                        Text("Icon:")
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        TextField("Emoji", text: $button.icon)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        
                        Text("e.g., 🌟, ⚙️, 📁")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else if button.actionType != .settings {
                    TextField(actionPlaceholder, text: $button.actionValue)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Button(isExpanded ? "Less" : "More") {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .font(.caption)
            .buttonStyle(.plain)
            .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    var actionPlaceholder: String {
        switch button.actionType {
        case .icon: return ""
        case .app: return "com.apple.Safari"
        case .folder: return "/Users/username/Folder"
        case .url: return "https://example.com"
        case .script: return "say \"Hello\""
        case .settings: return ""
        case .music: return "playPause"
        }
    }
}

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
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
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 600)
        self.contentView = hostingView
        self.delegate = self
    }
}

struct ZenithSettingsView: View {
    @State private var showingImportAlert = false
    @State private var showingExportSuccess = false
    @State private var importError = false
    
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    appearanceSection()
                    customizationSection()
                    dockButtonsSection()
                    behaviorSection()
                    dataSection()
                    
                    HStack {
                        Spacer()
                        Button("Close") {
                            NSApp.keyWindow?.close()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
        }
        .frame(width: 400, height: 600)
        .alert("Import Successful", isPresented: $showingImportAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Export Saved", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your configuration has been exported to the Downloads folder.")
        }
        .alert("Import Failed", isPresented: $importError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The configuration file could not be imported. Please check the file format.")
        }
    }
    
    @ViewBuilder
    private func appearanceSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPEARANCE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            
            Toggle("High Contrast (Dark Glass)", isOn: Binding(
                get: { state.isDarkGlass },
                set: { state.isDarkGlass = $0 }
            ))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Button Shape")
                    .font(.caption)
                Picker("Button Shape", selection: Binding(
                    get: { state.buttonShape },
                    set: { state.buttonShape = $0 }
                )) {
                    ForEach(ButtonShape.allCases, id: \.self) { shape in
                        Text(shape.displayName).tag(shape)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Accent Color")
                    .font(.caption)
                Picker("Accent Color", selection: Binding(
                    get: { state.accentColor },
                    set: { state.accentColor = $0 }
                )) {
                    ForEach(AccentColor.allCases, id: \.self) { color in
                        Text(color.displayName).tag(color)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Contrast: \(Int(state.contrastLevel * 100))%")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.contrastLevel },
                        set: { state.contrastLevel = $0 }
                    ),
                    in: 0...1,
                    step: 0.05
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Dock Opacity: \(Int(state.dockOpacity * 100))%")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.dockOpacity },
                        set: { state.dockOpacity = $0 }
                    ),
                    in: 0.2...1,
                    step: 0.05
                )
            }
        }
    }
    
    @ViewBuilder
    private func customizationSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SIZE & SPACING").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Arc Spread: \(Int(state.arcSpread))")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.arcSpread },
                        set: { state.arcSpread = $0 }
                    ),
                    in: 20...150,
                    step: 1
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Drop Depth: \(Int(state.dropDepth))")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.dropDepth },
                        set: { state.dropDepth = $0 }
                    ),
                    in: 0...100,
                    step: 1
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Icon Size: \(Int(state.iconSize))")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.iconSize },
                        set: { state.iconSize = $0 }
                    ),
                    in: 10...30,
                    step: 1
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hover Lift: \(Int(state.hoverLift))")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.hoverLift },
                        set: { state.hoverLift = $0 }
                    ),
                    in: 0...15,
                    step: 1
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Border Width: \(Int(state.borderWidth))px")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.borderWidth },
                        set: { state.borderWidth = $0 }
                    ),
                    in: 0...3,
                    step: 0.5
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notch Width: \(Int(state.notchWidth))")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.notchWidth },
                        set: { state.notchWidth = $0 }
                    ),
                    in: 50...250,
                    step: 10
                )
            }
        }
    }
    
    @ViewBuilder
    private func behaviorSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BEHAVIOR").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            
            Toggle("Haptic Feedback", isOn: Binding(
                get: { state.hapticFeedback },
                set: { state.hapticFeedback = $0 }
            ))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Auto-Show Delay: \(String(format: "%.1f", state.autoShowDelay))s")
                    .font(.caption)
                Slider(
                    value: Binding(
                        get: { state.autoShowDelay },
                        set: { state.autoShowDelay = $0 }
                    ),
                    in: 0...1,
                    step: 0.1
                )
            }
        }
    }
    
    @ViewBuilder
    private func dockButtonsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("DOCK BUTTONS").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                Spacer()
                Button("Reset to Default") {
                    state.dockButtons = DockButton.defaultButtons
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            HStack {
                Text("Number of Buttons: \(state.dockButtons.count)")
                    .font(.caption)
                
                Stepper("", value: Binding(
                    get: { state.dockButtons.count },
                    set: { newCount in
                        let diff = newCount - state.dockButtons.count
                        if diff > 0 {
                            for _ in 0..<diff {
                                state.addDockButton()
                            }
                        } else if diff < 0 {
                            for _ in 0..<(-diff) {
                                if !state.dockButtons.isEmpty {
                                    state.removeDockButton(at: state.dockButtons.count - 1)
                                }
                            }
                        }
                    }
                ), in: 1...12)
                .labelsHidden()
            }
            
            HStack {
                Text("Style:")
                    .font(.caption)
                
                Picker("", selection: $state.dockStyle) {
                    ForEach(DockButton.DockStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Divider()
            
            ForEach(Array(state.dockButtons.enumerated()), id: \.element.id) { index, button in
                DockButtonEditor(button: $state.dockButtons[index], onDelete: {
                    state.removeDockButton(at: index)
                })
            }
        }
    }
    
    @ViewBuilder
    private func dataSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Export Config") {
                    if let url = state.exportConfiguration() {
                        let destination = FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Downloads")
                            .appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.copyItem(at: url, to: destination)
                        showingExportSuccess = true
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Import Config") {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.json]
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        if !state.importConfiguration(from: url) {
                            importError = true
                        } else {
                            showingImportAlert = true
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 12) {
                if state.hasCustomSegments {
                    Button("Reset to Defaults") {
                        state.resetToDefaultSegments()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            
            if state.hasCustomSegments {
                Text("Using custom segment configuration").font(.caption).foregroundColor(.green)
            } else {
                Text("Using default segment configuration").font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
