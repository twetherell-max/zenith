import AppKit
import SwiftUI

extension Notification.Name {
    static let openAIConfig = Notification.Name("openAIConfig")
}

struct DockButtonEditor: View {
    @Binding var button: DockButton
    let onDelete: () -> Void
    @State private var isExpanded = false
    @State private var showingPresetPicker = false
    @State private var showingAppPicker = false
    @State private var showingFolderPicker = false
    
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
                    musicConfigView
                } else if button.actionType == .note {
                    Text("Quick note capture - click to add a note")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if button.actionType == .icon {
                    iconConfigView
                } else if button.actionType == .app {
                    appConfigView
                } else if button.actionType == .folder {
                    folderConfigView
                } else if button.actionType == .url {
                    TextField("URL", text: $button.actionValue)
                        .textFieldStyle(.roundedBorder)
                } else if button.actionType == .script {
                    scriptConfigView
                }
                
                quickActionsConfigView
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
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView(selectedBundleId: $button.actionValue, selectedIcon: $button.icon, selectedTitle: $button.title)
        }
        .sheet(isPresented: $showingFolderPicker) {
            FolderPickerView(selectedPath: $button.actionValue)
        }
    }
    
    private var musicConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Service:")
                    .font(.caption)
                    .frame(width: 60, alignment: .leading)
                Picker("", selection: $button.musicService) {
                    ForEach(DockButton.MusicService.allCases, id: \.self) { service in
                        Text(service.displayName).tag(service)
                    }
                }
                .pickerStyle(.segmented)
            }
            
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
        }
    }
    
    private var iconConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Icon", text: $button.icon)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                
                Button("Presets") {
                    showingPresetPicker.toggle()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            if showingPresetPicker {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                    ForEach(DockButton.presetIcons.prefix(24)) { preset in
                        Button(action: {
                            button.icon = preset.emoji
                            showingPresetPicker = false
                        }) {
                            Text(preset.emoji)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .help("\(preset.name)")
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var appConfigView: some View {
        HStack {
            TextField("Bundle ID", text: $button.actionValue)
                .textFieldStyle(.roundedBorder)
            Button("Browse") {
                showingAppPicker = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    private var folderConfigView: some View {
        HStack {
            TextField("Folder Path", text: $button.actionValue)
                .textFieldStyle(.roundedBorder)
            Button("Browse") {
                showingFolderPicker = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    private var scriptConfigView: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("AppleScript", text: $button.actionValue)
                .textFieldStyle(.roundedBorder)
            Text("e.g., tell app \"System Events\" to key code 53")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var quickActionsConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("Quick Actions")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Toggle("Enable Quick Actions", isOn: $button.quickActionsEnabled)
                .font(.caption)
            
            if button.quickActionsEnabled {
                HStack {
                    Text("Trigger:")
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    
                    Picker("", selection: $button.quickActionTrigger) {
                        ForEach(DockButton.QuickActionTrigger.allCases, id: \.self) { trigger in
                            Text(trigger.displayName).tag(trigger)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                HStack {
                    Text("Delay:")
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    
                    Slider(value: $button.quickActionDelay, in: 0.2...2.0, step: 0.1)
                    
                    Text(String(format: "%.1fs", button.quickActionDelay))
                        .font(.caption)
                        .frame(width: 30)
                }
                
                if button.actionType == .app {
                    Toggle("Show Recent Documents", isOn: $button.showRecentDocs)
                        .font(.caption)
                }
                
                Text("Pinned items: \(button.pinnedItems.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AppPickerView: View {
    @Binding var selectedBundleId: String
    @Binding var selectedIcon: String
    @Binding var selectedTitle: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredApps: [(name: String, bundleId: String)] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> (String, String)? in
                guard let name = app.localizedName, let bundleId = app.bundleIdentifier else { return nil }
                return (name, bundleId)
            }
            .sorted { $0.0 < $1.0 }
            .filter { searchText.isEmpty || $0.0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            Text("Select App")
                .font(.headline)
                .padding()
            
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            List(filteredApps, id: \.bundleId) { appItem in
                Button(action: {
                    selectedBundleId = appItem.bundleId
                    selectedTitle = appItem.name
                    selectedIcon = "🖥️"
                    dismiss()
                }) {
                    HStack {
                        if let runningApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == appItem.bundleId }),
                           let icon = runningApp.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(appItem.name)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
        .frame(width: 350, height: 400)
    }
}

struct FolderPickerView: View {
    @Binding var selectedPath: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Select Folder")
                .font(.headline)
                .padding()
            
            Text(selectedPath.isEmpty ? "No folder selected" : selectedPath)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.horizontal)
            
            Button("Choose Folder...") {
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                
                if panel.runModal() == .OK, let url = panel.url {
                    selectedPath = url.path
                    dismiss()
                }
            }
            .buttonStyle(.bordered)
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .padding(.bottom)
        }
        .frame(width: 350, height: 200)
    }
}

class ZenithSettingsWindow: NSWindow, NSWindowDelegate {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
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
        self.minSize = NSSize(width: 500, height: 500)
        
        let settingsView = ZenithSettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 600, height: 700)
        self.contentView = hostingView
        self.delegate = self
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case appearance = "Appearance"
    case layout = "Layout"
    case behavior = "Behavior"
    case interaction = "Interaction"
    case sound = "Sound"
    case widgets = "Widgets"
    case dockButtons = "Dock Buttons"
    case advanced = "Advanced"
    case shortcuts = "Shortcuts"
    case data = "Data"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .appearance: return "paintbrush.fill"
        case .layout: return "square.grid.2x2"
        case .behavior: return "slider.horizontal.3"
        case .interaction: return "hand.point.up.fill"
        case .sound: return "speaker.wave.3.fill"
        case .widgets: return "puzzlepiece.fill"
        case .dockButtons: return "square.grid.3x3.fill"
        case .advanced: return "gearshape.2.fill"
        case .shortcuts: return "keyboard"
        case .data: return "folder.fill"
        }
    }
}

enum ZenithPreset: String, CaseIterable {
    case minimal = "Minimal"
    case balanced = "Balanced"
    case powerful = "Powerful"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .minimal: return "Clean, subtle, stays out of your way"
        case .balanced: return "Default settings, good for most users"
        case .powerful: return "Large icons, deep arc, maximum impact"
        case .custom: return "Your custom configuration"
        }
    }
}

struct ZenithSettingsView: View {
    @State private var selectedSection: SettingsSection = .overview
    @State private var showingImportAlert = false
    @State private var showingExportSuccess = false
    @State private var importError = false
    @State private var showingAIConfig = false
    @State private var selectedPreset: ZenithPreset = .custom
    
    @ObservedObject private var state = ZenithState.shared
    
    var body: some View {
        HStack(spacing: 0) {
            sidebarView
            Divider()
            contentView
        }
        .frame(width: 600, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAIConfig) {
            AIConfigView()
        }
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
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                Text("ZENITH")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Button(action: {
                    AppDelegate.shared.closeSettings()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(SettingsSection.allCases) { section in
                        Button(action: { selectedSection = section }) {
                            HStack(spacing: 8) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 14))
                                    .frame(width: 20)
                                Text(section.rawValue)
                                    .font(.system(size: 13))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedSection == section ? Color.orange.opacity(0.2) : Color.clear)
                            .foregroundColor(selectedSection == section ? .orange : .primary)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
        .frame(width: 160)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader
                
                switch selectedSection {
                case .overview:
                    overviewSection
                case .appearance:
                    appearanceSection
                case .layout:
                    layoutSection
                case .behavior:
                    behaviorSection
                case .interaction:
                    interactionSection
                case .sound:
                    soundSection
                case .widgets:
                    widgetsSection
                case .dockButtons:
                    dockButtonsSection
                case .advanced:
                    advancedSection
                case .shortcuts:
                    shortcutsSection
                case .data:
                    dataSection
                }
            }
            .padding(24)
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: selectedSection.icon)
                .font(.system(size: 20))
                .foregroundColor(.orange)
            Text(selectedSection.rawValue)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Quick Setup", systemImage: "bolt.fill")) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a preset to get started quickly, or customize individual settings below.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(ZenithPreset.allCases, id: \.self) { preset in
                        Button(action: { applyPreset(preset) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(preset.rawValue)
                                        .font(.headline)
                                    Text(preset.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedPreset == preset {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(12)
                            .background(selectedPreset == preset ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Feature Summary", systemImage: "list.bullet")) {
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "paintbrush", title: "Appearance", subtitle: "Colors, shapes, style")
                    featureRow(icon: "square.grid.2x2", title: "Layout", subtitle: "Arc, spacing, positioning")
                    featureRow(icon: "slider.horizontal.3", title: "Behavior", subtitle: "Haptics, animations, Zen Mode")
                    featureRow(icon: "puzzlepiece.fill", title: "Widgets", subtitle: "AI, notifications")
                    featureRow(icon: "keyboard", title: "Shortcuts", subtitle: "Keyboard shortcuts")
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Visual Style", systemImage: "paintbrush")) {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("High Contrast (Dark Glass)", isOn: $state.isDarkGlass)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Button Shape")
                            .font(.caption)
                        Picker("", selection: $state.buttonShape) {
                            ForEach(ButtonShape.allCases, id: \.self) { shape in
                                Text(shape.displayName).tag(shape)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dock Style")
                            .font(.caption)
                        Picker("", selection: $state.dockStyle) {
                            ForEach(DockButton.DockStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if state.dockStyle == .minimal {
                        Picker("Outline Color", selection: $state.useWhiteOutline) {
                            Text("White").tag(true)
                            Text("Accent").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Accent Color", systemImage: "paintpalette.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(AccentColor.allCases, id: \.self) { color in
                            Button(action: { state.accentColor = color }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(NSColor(hex: color.colorValue) ?? .white))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(state.accentColor == color ? Color.orange : Color.clear, lineWidth: 3)
                                        )
                                    Text(color.displayName)
                                        .font(.caption2)
                                        .foregroundColor(state.accentColor == color ? .orange : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Adjustments", systemImage: "slider.horizontal")) {
                VStack(alignment: .leading, spacing: 16) {
                    sliderRow(label: "Contrast", value: $state.contrastLevel, range: 0...1, displayTransform: { "\(Int($0 * 100))%" })
                    sliderRow(label: "Dock Opacity", value: $state.dockOpacity, range: 0.2...1, displayTransform: { "\(Int($0 * 100))%" })
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Dock Layout", systemImage: "square.grid.2x2")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: { state.dockLayout = .radial }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(state.dockLayout == .radial ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "circle.dashed")
                                        .font(.system(size: 28))
                                        .foregroundColor(state.dockLayout == .radial ? .orange : .secondary)
                                }
                                Text("Radial")
                                    .font(.caption)
                                    .foregroundColor(state.dockLayout == .radial ? .orange : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { state.dockLayout = .list }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(state.dockLayout == .list ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 28))
                                        .foregroundColor(state.dockLayout == .list ? .orange : .secondary)
                                }
                                Text("Horizontal")
                                    .font(.caption)
                                    .foregroundColor(state.dockLayout == .list ? .orange : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Positioning", systemImage: "arrow.up.and.down")) {
                VStack(alignment: .leading, spacing: 16) {
                    if state.dockLayout == .radial {
                        sliderRow(label: "Arc Spread", value: $state.arcSpread, range: 20...150, displayTransform: { "\(Int($0))" })
                        sliderRow(label: "Drop Depth", value: $state.dropDepth, range: 0...100, displayTransform: { "\(Int($0))" })
                    }
                    sliderRow(label: "Icon Size", value: $state.iconSize, range: 10...30, displayTransform: { "\(Int($0))" })
                    sliderRow(label: "Hover Lift", value: $state.hoverLift, range: 0...15, displayTransform: { "\(Int($0))" })
                    sliderRow(label: "Border Width", value: $state.borderWidth, range: 0...3, displayTransform: { String(format: "%.1fpx", $0) })
                    Divider()
                    sliderRow(label: "Bar Height", value: $state.barHeight, range: 4...30, displayTransform: { "\(Int($0))px" })
                    sliderRow(label: "Bar Opacity", value: $state.barOpacity, range: 0.1...1.0, displayTransform: { "\(Int($0 * 100))%" })
                    sliderRow(label: "Notch Width", value: $state.notchWidth, range: 50...250, displayTransform: { "\(Int($0))" })
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func layoutPreviewIcon(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("General", systemImage: "gear")) {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Haptic Feedback", isOn: $state.hapticFeedback)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        sliderRow(label: "Auto-Show Delay", value: $state.autoShowDelay, range: 0...1, displayTransform: { String(format: "%.1fs", $0) })
                        Text("Delay before dock appears on hover")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Focus Mode", systemImage: "moon.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Zen Mode (Cmd+Shift+Z)", isOn: $state.zenModeEnabled)
                    if state.zenModeEnabled {
                        Text("Press Cmd+Shift+Z to hide/show dock. When hidden, press again to reveal for 5 seconds.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Toggle("Focus Dimming", isOn: $state.focusDimmingEnabled)
                    if state.focusDimmingEnabled {
                        Text("Dims the screen when dock is active to help focus.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Animation", systemImage: "sparkles")) {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Spring Animations", isOn: $state.useSpringAnimations)
                    
                    if state.useSpringAnimations {
                        VStack(alignment: .leading, spacing: 12) {
                            sliderRow(label: "Stiffness", value: $state.springStiffness, range: 100...500, displayTransform: { "\(Int($0))" })
                            Text("Lower = bouncier, Higher = snappier")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            sliderRow(label: "Damping", value: $state.springDamping, range: 5...40, displayTransform: { "\(Int($0))" })
                            Text("Lower = more oscillation, Higher = faster settle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var widgetsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Quick Query AI", systemImage: "sparkles")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Quick Query", isOn: $state.aiEnabled)
                    
                    if state.aiEnabled {
                        HStack {
                            if AIHelper.shared.isConfigured {
                                Label("API key configured", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Label("API key required", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            Button("Configure") {
                                showingAIConfig = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption)
                        
                        Text("Click the sparkle icon in the dock bar to ask questions.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Notifications", systemImage: "bell.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Notification Pulse", isOn: $state.notificationPulseEnabled)
                    
                    if state.notificationPulseEnabled {
                        Toggle("Show Preview on Hover", isOn: $state.showNotificationPreview)
                            .controlSize(.small)
                        
                        Text("Bar pulses blue when you have unread notifications. Hover to see preview.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Music Display", systemImage: "music.note")) {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Music Display", selection: $state.musicDisplayMode) {
                        ForEach(DockButton.MusicDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Icon: Click to control | Artwork: Show album art | Popup: Full track info")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var interactionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Hover Breach", systemImage: "clock.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Hover Breach", isOn: $state.hoverBreachEnabled)
                    
                    if state.hoverBreachEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            sliderRow(label: "Breach Delay", value: $state.hoverBreachDelay, range: 0...0.5, displayTransform: { String(format: "%.1fs", $0) })
                            Text("Delay before dock appears - prevents accidental triggers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Scroll-to-Select", systemImage: "scroll.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Scroll-to-Select", isOn: $state.scrollToSelectEnabled)
                    
                    if state.scrollToSelectEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            sliderRow(label: "Sensitivity", value: $state.scrollSensitivity, range: 0.5...2.0, displayTransform: { String(format: "%.1fx", $0) })
                            Text("Scroll wheel to navigate through icons")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Mini Arc", systemImage: "rectangle.expand.vertical")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Right-Click Mini Arc", isOn: $state.miniArcEnabled)
                    
                    Text("Right-click on the bar to show a compact mini-arc view")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("The Wash Launch", systemImage: "arrow.up.right.circle.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Wash Launch", isOn: $state.washLaunchEnabled)
                    
                    if state.washLaunchEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            sliderRow(label: "Scale Amount", value: $state.washLaunchScale, range: 1.0...1.5, displayTransform: { String(format: "%.1fx", $0) })
                            Text("Icons fan out further and fade when launching apps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Soundscapes", systemImage: "speaker.wave.3.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Soundscapes", isOn: $state.soundscapesEnabled)
                    
                    if state.soundscapesEnabled {
                        Toggle("Expansion Sound", isOn: $state.expansionSound)
                        Toggle("Selection Sound", isOn: $state.selectionSound)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            sliderRow(label: "Volume", value: $state.soundVolume, range: 0...1, displayTransform: { "\(Int($0 * 100))%" })
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Haptic Profiles", systemImage: "hand.tap.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Haptic Profiles", isOn: $state.hapticProfilesEnabled)
                    
                    if state.hapticProfilesEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            sliderRow(label: "Light Haptic", value: $state.lightHapticWeight, range: 0.1...1.0, displayTransform: { String(format: "%.1f", $0) })
                            sliderRow(label: "Heavy Haptic", value: $state.heavyHapticWeight, range: 0.1...1.0, displayTransform: { String(format: "%.1f", $0) })
                            Text("Adjust haptic intensity for different actions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Zenith Forge", systemImage: "hammer.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Zenith Forge", isOn: $state.forgeEnabled)
                    
                    if state.forgeEnabled {
                        HStack {
                            Text("Scripts Path:")
                                .font(.caption)
                            TextField("~/Zenith/Scripts", text: $state.forgeScriptsPath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                        }
                        
                        Text("Load custom scripts from a local folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Deep Shortcuts", systemImage: "link")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Shortcuts Integration", isOn: $state.shortcutsIntegrationEnabled)
                    
                    if state.shortcutsIntegrationEnabled {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Connect Zenith to Apple Shortcuts for automations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var dockButtonsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Configuration", systemImage: "square.grid.3x3")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Number of Buttons:")
                            .font(.caption)
                        Stepper("", value: Binding(
                            get: { state.dockButtons.count },
                            set: { newCount in
                                let diff = newCount - state.dockButtons.count
                                if diff > 0 {
                                    for _ in 0..<diff { state.addDockButton() }
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
                        Text("\(state.dockButtons.count)")
                            .font(.caption)
                            .frame(width: 20)
                    }
                    
                    Divider()
                    
                    Picker("Music Display", selection: $state.musicDisplayMode) {
                        ForEach(DockButton.MusicDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 8)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Buttons")
                        .font(.headline)
                    Spacer()
                    Button("Reset to Default") {
                        state.dockButtons = DockButton.defaultButtons
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                ForEach(Array(state.dockButtons.enumerated()), id: \.element.id) { index, _ in
                    DockButtonEditor(button: $state.dockButtons[index]) {
                        state.removeDockButton(at: index)
                    }
                }
            }
        }
    }
    
    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Keyboard Shortcuts", systemImage: "keyboard")) {
                VStack(alignment: .leading, spacing: 16) {
                    shortcutRow(keys: "Cmd+Shift+Z", description: "Toggle Zen Mode / Show Dock")
                    shortcutRow(keys: "Cmd+Option+J", description: "Pulse Animation")
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Global shortcuts work even when Zenith is in the background.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Dock Actions", systemImage: "hand.tap.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.orange)
                        Text("Click on bar")
                        Spacer()
                        Text("Show/Hide Dock")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.orange)
                        Text("Hover on bar")
                        Spacer()
                        Text("Show dock temporarily")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.orange)
                        Text("Hover on icon")
                        Spacer()
                        Text("Preview / Quick Actions")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func shortcutRow(keys: String, description: String) -> some View {
        HStack {
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            
            Text(description)
                .font(.caption)
            
            Spacer()
        }
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Label("Configuration", systemImage: "doc.fill")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: exportConfig) {
                            Label("Export Config", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: importConfig) {
                            Label("Import Config", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Export your Zenith configuration to share or backup.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("Segments", systemImage: "rectangle.3.group")) {
                VStack(alignment: .leading, spacing: 8) {
                    if state.hasCustomSegments {
                        Button("Reset to Defaults") {
                            state.resetToDefaultSegments()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Label("Using custom segment configuration", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Label("Using default segment configuration", systemImage: "info.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox(label: Label("About", systemImage: "info.circle")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "circle.grid.cross.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Zenith")
                                .font(.headline)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("A minimalist radial dock for macOS.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func applyPreset(_ preset: ZenithPreset) {
        selectedPreset = preset
        
        switch preset {
        case .minimal:
            state.iconSize = 12
            state.arcSpread = 40
            state.dropDepth = 15
            state.dockOpacity = 0.6
            state.hoverLift = 4
            state.borderWidth = 0.5
            state.notchWidth = 100
            state.dockStyle = .minimal
            state.useWhiteOutline = true
            
        case .balanced:
            state.iconSize = 14
            state.arcSpread = 80
            state.dropDepth = 30
            state.dockOpacity = 0.8
            state.hoverLift = 6
            state.borderWidth = 1.0
            state.notchWidth = 150
            state.dockStyle = .normal
            state.useWhiteOutline = true
            
        case .powerful:
            state.iconSize = 22
            state.arcSpread = 120
            state.dropDepth = 60
            state.dockOpacity = 1.0
            state.hoverLift = 10
            state.borderWidth = 2.0
            state.notchWidth = 200
            state.dockStyle = .glow
            state.useWhiteOutline = false
            
        case .custom:
            break
        }
    }
    
    private func exportConfig() {
        if let url = state.exportConfiguration() {
            let destination = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Downloads")
                .appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.copyItem(at: url, to: destination)
            showingExportSuccess = true
        }
    }
    
    private func importConfig() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            if !state.importConfiguration(from: url) {
                importError = true
            } else {
                showingImportAlert = true
                selectedPreset = .custom
            }
        }
    }
    
    private func sliderRow(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        displayTransform: @escaping (Double) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text(displayTransform(value.wrappedValue))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
            Slider(value: value, in: range)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
