import SwiftUI
import Combine
import Foundation
import AppKit

class ZenithState: ObservableObject {
    static let shared = ZenithState()
    
    private let persistence = PersistenceManager.shared
    
    @Published var arcSpread: Double {
        didSet { saveSettings() }
    }
    
    @Published var dropDepth: Double {
        didSet { saveSettings() }
    }
    
    @Published var iconSize: Double {
        didSet { saveSettings() }
    }
    
    @Published var isDarkGlass: Bool {
        didSet { saveSettings() }
    }
    
    @Published var buttonShape: ButtonShape {
        didSet { saveSettings() }
    }
    
    @Published var accentColor: AccentColor {
        didSet { saveSettings() }
    }
    
    @Published var contrastLevel: Double {
        didSet { saveSettings() }
    }
    
    @Published var dockOpacity: Double {
        didSet { saveSettings() }
    }
    
    @Published var hapticFeedback: Bool {
        didSet { saveSettings() }
    }
    
    @Published var autoShowDelay: Double {
        didSet { saveSettings() }
    }
    
    @Published var hoverLift: Double {
        didSet { saveSettings() }
    }
    
    @Published var borderWidth: Double {
        didSet { saveSettings() }
    }
    
    @Published var notchWidth: Double {
        didSet { saveSettings() }
    }
    
    @Published var dockButtons: [DockButton] {
        didSet { saveDockButtons() }
    }
    
    @Published var dockStyle: DockButton.DockStyle {
        didSet { saveSettings() }
    }
    
    @Published var useWhiteOutline: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var barHeight: Double = 20 {
        didSet { saveSettings() }
    }
    
    @Published var barOpacity: Double = 0.6 {
        didSet { saveSettings() }
    }
    
    @Published var isSettingsOpen: Bool = false
    @Published var isExpanded: Bool = false
    
    @Published var musicDisplayMode: DockButton.MusicDisplayMode = .icon {
        didSet { saveSettings() }
    }
    
    @Published var dockLayout: DockButton.DockLayout = .radial {
        didSet { saveSettings() }
    }
    
    @Published var zenModeEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var zenModeHidden: Bool = false
    
    @Published var focusDimmingEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var springStiffness: Double = 300.0 {
        didSet { saveSettings() }
    }
    
    @Published var springDamping: Double = 20.0 {
        didSet { saveSettings() }
    }
    
    @Published var useSpringAnimations: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var aiEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var notificationPulseEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var showNotificationPreview: Bool = true {
        didSet { saveSettings() }
    }
    
    // Hover Breach
    @Published var hoverBreachEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var hoverBreachDelay: Double = 0.2 {
        didSet { saveSettings() }
    }
    
    // Soundscapes
    @Published var soundscapesEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var expansionSound: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var selectionSound: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var soundVolume: Double = 0.5 {
        didSet { saveSettings() }
    }
    
    // Scroll-to-Select
    @Published var scrollToSelectEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var scrollSensitivity: Double = 1.0 {
        didSet { saveSettings() }
    }
    
    // Right-Click Mini Arc
    @Published var miniArcEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    // The Wash Launch
    @Published var washLaunchEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var washLaunchScale: Double = 1.2 {
        didSet { saveSettings() }
    }
    
    // Haptic Profiles
    @Published var hapticProfilesEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var lightHapticWeight: Double = 0.5 {
        didSet { saveSettings() }
    }
    
    @Published var heavyHapticWeight: Double = 1.0 {
        didSet { saveSettings() }
    }
    
    // Zenith Forge
    @Published var forgeEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var forgeScriptsPath: String = ""
    
    // Deep Shortcuts
    @Published var shortcutsIntegrationEnabled: Bool = false {
        didSet { saveSettings() }
    }
    
    // Minimal Notch Mode
    @Published var appMode: AppMode = .productivity {
        didSet { saveSettings() }
    }
    
    @Published var notchOverlayEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var notchColor: NotchColor = .black {
        didSet { saveSettings() }
    }
    
    @Published var notchOpacity: Double = 1.0 {
        didSet { saveSettings() }
    }
    
    @Published var notchCornerRadius: Double = 18.0 {
        didSet { saveSettings() }
    }
    
    @Published var notchHeight: Double = 30.0 {
        didSet { saveSettings() }
    }
    
    @Published var multiMonitorMode: MultiMonitorMode = .primaryOnly {
        didSet { saveSettings() }
    }
    
    // Enhanced Notch Management
    @Published var notchRenderMode: NotchRenderMode = .notchOnly {
        didSet { saveSettings() }
    }
    
    @Published var notchPreset: NotchPreset = .standard {
        didSet { 
            applyNotchPreset(notchPreset)
            saveSettings() 
        }
    }
    
    @Published var enableMultiMonitor: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var edgeToEdgeOpacity: Double = 0.3 {
        didSet { saveSettings() }
    }
    
    @Published var notchAnimationDuration: Double = 0.2 {
        didSet { saveSettings() }
    }
    
    @Published var keyboardShortcutEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var toggleNotchShortcut: String = "cmd+shift+n" {
        didSet { saveSettings() }
    }
    
    // Radial Menu System
    @Published var radialMenuItems: [RadialMenuItem] {
        didSet { saveRadialMenuItems() }
    }
    
    @Published var radialMenuEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuMode: RadialMenuMode = .click {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuRadius: Double = 120.0 {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuItemSize: Double = 50.0 {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuAnimationStyle: RadialAnimationStyle = .spring {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuShowLabels: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var radialMenuIsOpen: Bool = false
    
    // Arc Level System
    @Published var currentLevel: Int = 1
    @Published var expandedCategoryId: UUID?
    @Published var arcSegments: [ArcSegment] = []
    @Published var hasCustomSegments: Bool = false
    
    // Gesture tracking
    @Published var gestureStartTime: Date?
    @Published var isLongPress: Bool = false
    @Published var hoveredSegmentId: UUID?
    
    // Animation
    var animationResponse: Double {
        switch currentLevel {
        case 1: return 0.8
        case 2: return 0.6
        default: return 0.5
        }
    }
    
    var animationDamping: Double {
        switch currentLevel {
        case 1: return 0.7
        case 2: return 0.65
        default: return 0.6
        }
    }
    
    // Computed: current visible segments based on level
    var visibleSegments: [ArcSegment] {
        guard currentLevel > 1, let expandedId = expandedCategoryId else {
            return arcSegments
        }
        
        if let category = findSegment(by: expandedId) {
            return category.children ?? []
        }
        return arcSegments
    }
    
    func findSegment(by id: UUID) -> ArcSegment? {
        func search(_ segments: [ArcSegment]) -> ArcSegment? {
            for segment in segments {
                if segment.id == id { return segment }
                if let children = segment.children, let found = search(children) {
                    return found
                }
            }
            return nil
        }
        return search(arcSegments)
    }
    
    func expandCategory(_ segment: ArcSegment) {
        if segment.isCategory, let children = segment.children, !children.isEmpty {
            expandedCategoryId = segment.id
            currentLevel = segment.level + 1
        }
    }
    
    func collapseToLevel(_ level: Int) {
        if level == 1 {
            expandedCategoryId = nil
            currentLevel = 1
        }
    }
    
    private func applyNotchPreset(_ preset: NotchPreset) {
        switch preset {
        case .standard:
            notchWidth = 150
            notchHeight = 30
            notchCornerRadius = 18
            
        case .mini:
            notchWidth = 100
            notchHeight = 25
            notchCornerRadius = 12
            
        case .large:
            notchWidth = 200
            notchHeight = 35
            notchCornerRadius = 20
            
        case .custom:
            break // User customizes manually
        }
    }
    
    func executeAction(for segment: ArcSegment) {
        switch segment.actionType {
        case .app:
            if let bundleId = segment.action {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                    NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
                }
            }
        case .folder:
            if let folderName = segment.action {
                let homeDir = FileManager.default.homeDirectoryForCurrentUser
                let folderURL: URL
                switch folderName {
                case "downloads":
                    folderURL = homeDir.appendingPathComponent("Downloads")
                case "documents":
                    folderURL = homeDir.appendingPathComponent("Documents")
                case "desktop":
                    folderURL = homeDir.appendingPathComponent("Desktop")
                default:
                    folderURL = homeDir.appendingPathComponent(folderName.capitalized)
                }
                NSWorkspace.shared.open(folderURL)
            }
        case .settings:
            AppDelegate.shared.showSettingsWindow()
        case .media:
            handleMediaAction(segment.action)
        case .clipboard, .none:
            break
        }
    }
    
    private func handleMediaAction(_ action: String?) {
        var script = ""
        switch action {
        case "media-playpause":
            script = "tell application \"System Events\" to key code 16"
        case "media-next":
            script = "tell application \"System Events\" to key code 45"
        case "media-previous":
            script = "tell application \"System Events\" to key code 50"
        default:
            return
        }
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }
    
    // DEBUG ID: If you see two different numbers, there are two windows.
    let debugID = Int.random(in: 1...100)
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private init() {
        let settings = persistence.loadUserSettings()
        
        self.barHeight = settings.barHeight
        self.barOpacity = settings.barOpacity
        self.arcSpread = settings.arcSpread
        self.dropDepth = settings.dropDepth
        self.iconSize = settings.iconSize
        self.isDarkGlass = settings.isDarkGlass
        self.buttonShape = settings.buttonShape
        self.accentColor = settings.accentColor
        self.contrastLevel = settings.contrastLevel
        self.dockOpacity = settings.dockOpacity
        self.hapticFeedback = settings.hapticFeedback
        self.autoShowDelay = settings.autoShowDelay
        self.hoverLift = settings.hoverLift
        self.borderWidth = settings.borderWidth
        self.notchWidth = settings.notchWidth
        self.dockButtons = persistence.loadDockButtons() ?? DockButton.defaultButtons
        self.dockStyle = settings.dockStyle
        self.zenModeEnabled = settings.zenModeEnabled
        self.focusDimmingEnabled = settings.focusDimmingEnabled
        self.springStiffness = settings.springStiffness
        self.springDamping = settings.springDamping
        self.useSpringAnimations = settings.useSpringAnimations
        self.aiEnabled = settings.aiEnabled
        self.notificationPulseEnabled = settings.notificationPulseEnabled
        self.showNotificationPreview = settings.showNotificationPreview
        self.hoverBreachEnabled = settings.hoverBreachEnabled
        self.hoverBreachDelay = settings.hoverBreachDelay
        self.soundscapesEnabled = settings.soundscapesEnabled
        self.expansionSound = settings.expansionSound
        self.selectionSound = settings.selectionSound
        self.soundVolume = settings.soundVolume
        self.scrollToSelectEnabled = settings.scrollToSelectEnabled
        self.scrollSensitivity = settings.scrollSensitivity
        self.miniArcEnabled = settings.miniArcEnabled
        self.washLaunchEnabled = settings.washLaunchEnabled
        self.washLaunchScale = settings.washLaunchScale
        self.hapticProfilesEnabled = settings.hapticProfilesEnabled
        self.lightHapticWeight = settings.lightHapticWeight
        self.heavyHapticWeight = settings.heavyHapticWeight
        self.forgeEnabled = settings.forgeEnabled
        self.forgeScriptsPath = settings.forgeScriptsPath
        self.shortcutsIntegrationEnabled = settings.shortcutsIntegrationEnabled
        self.appMode = settings.appMode
        self.notchOverlayEnabled = settings.notchOverlayEnabled
        self.notchColor = settings.notchColor
        self.notchOpacity = settings.notchOpacity
        self.notchCornerRadius = settings.notchCornerRadius
        self.notchHeight = settings.notchHeight
        self.multiMonitorMode = settings.multiMonitorMode
        self.notchRenderMode = settings.notchRenderMode
        self.notchPreset = settings.notchPreset
        self.enableMultiMonitor = settings.enableMultiMonitor
        self.edgeToEdgeOpacity = settings.edgeToEdgeOpacity
        self.notchAnimationDuration = settings.notchAnimationDuration
        self.keyboardShortcutEnabled = settings.keyboardShortcutEnabled
        self.toggleNotchShortcut = settings.toggleNotchShortcut
        self.radialMenuItems = persistence.loadRadialMenuItems() ?? RadialMenuItem.defaults
        self.radialMenuEnabled = settings.radialMenuEnabled
        self.radialMenuMode = settings.radialMenuMode
        self.radialMenuRadius = settings.radialMenuRadius
        self.radialMenuItemSize = settings.radialMenuItemSize
        self.radialMenuAnimationStyle = settings.radialMenuAnimationStyle
        self.radialMenuShowLabels = settings.radialMenuShowLabels
        
        if let customSegments = persistence.loadCustomSegments() {
            self.arcSegments = customSegments
            self.hasCustomSegments = true
        } else {
            self.arcSegments = ArcSegment.defaultRoot
        }
    }
    
    private func saveSettings() {
        let settings = UserSettings(
            barHeight: barHeight,
            barOpacity: barOpacity,
            arcSpread: arcSpread,
            dropDepth: dropDepth,
            iconSize: iconSize,
            isDarkGlass: isDarkGlass,
            buttonShape: buttonShape,
            accentColor: accentColor,
            contrastLevel: contrastLevel,
            dockOpacity: dockOpacity,
            hapticFeedback: hapticFeedback,
            autoShowDelay: autoShowDelay,
            hoverLift: hoverLift,
            borderWidth: borderWidth,
            notchWidth: notchWidth,
            dockStyle: dockStyle,
            zenModeEnabled: zenModeEnabled,
            focusDimmingEnabled: focusDimmingEnabled,
            springStiffness: springStiffness,
            springDamping: springDamping,
            useSpringAnimations: useSpringAnimations,
            washLaunchEnabled: washLaunchEnabled,
            washLaunchScale: washLaunchScale,
            aiEnabled: aiEnabled,
            notificationPulseEnabled: notificationPulseEnabled,
            showNotificationPreview: showNotificationPreview,
            hoverBreachEnabled: hoverBreachEnabled,
            hoverBreachDelay: hoverBreachDelay,
            scrollToSelectEnabled: scrollToSelectEnabled,
            scrollSensitivity: scrollSensitivity,
            miniArcEnabled: miniArcEnabled,
            soundscapesEnabled: soundscapesEnabled,
            expansionSound: expansionSound,
            selectionSound: selectionSound,
            soundVolume: soundVolume,
            hapticProfilesEnabled: hapticProfilesEnabled,
            lightHapticWeight: lightHapticWeight,
            heavyHapticWeight: heavyHapticWeight,
            forgeEnabled: forgeEnabled,
            forgeScriptsPath: forgeScriptsPath,
            shortcutsIntegrationEnabled: shortcutsIntegrationEnabled,
            appMode: appMode,
            notchOverlayEnabled: notchOverlayEnabled,
            notchColor: notchColor,
            notchOpacity: notchOpacity,
            notchCornerRadius: notchCornerRadius,
            notchHeight: notchHeight,
            multiMonitorMode: multiMonitorMode,
            notchRenderMode: notchRenderMode,
            notchPreset: notchPreset,
            enableMultiMonitor: enableMultiMonitor,
            edgeToEdgeOpacity: edgeToEdgeOpacity,
            notchAnimationDuration: notchAnimationDuration,
            keyboardShortcutEnabled: keyboardShortcutEnabled,
            toggleNotchShortcut: toggleNotchShortcut,
            radialMenuEnabled: radialMenuEnabled,
            radialMenuMode: radialMenuMode,
            radialMenuRadius: radialMenuRadius,
            radialMenuItemSize: radialMenuItemSize,
            radialMenuAnimationStyle: radialMenuAnimationStyle,
            radialMenuShowLabels: radialMenuShowLabels
        )
        persistence.saveUserSettings(settings)
    }
    
    private func saveRadialMenuItems() {
        persistence.saveRadialMenuItems(radialMenuItems)
    }
    
    func saveCustomSegments(_ segments: [ArcSegment]) {
        persistence.saveCustomSegments(segments)
        arcSegments = segments
        hasCustomSegments = true
    }
    
    func resetToDefaultSegments() {
        persistence.resetToDefaults()
        arcSegments = ArcSegment.defaultRoot
        hasCustomSegments = false
    }
    
    func exportConfiguration() -> URL? {
        return persistence.exportConfiguration()
    }
    
    func importConfiguration(from url: URL) -> Bool {
        let success = persistence.importConfiguration(from: url)
        if success {
            let settings = persistence.loadUserSettings()
            barHeight = settings.barHeight
            barOpacity = settings.barOpacity
            arcSpread = settings.arcSpread
            dropDepth = settings.dropDepth
            iconSize = settings.iconSize
            isDarkGlass = settings.isDarkGlass
            buttonShape = settings.buttonShape
            accentColor = settings.accentColor
            contrastLevel = settings.contrastLevel
            dockOpacity = settings.dockOpacity
            hapticFeedback = settings.hapticFeedback
            autoShowDelay = settings.autoShowDelay
            hoverLift = settings.hoverLift
            borderWidth = settings.borderWidth
            notchWidth = settings.notchWidth
            dockStyle = settings.dockStyle
            zenModeEnabled = settings.zenModeEnabled
            focusDimmingEnabled = settings.focusDimmingEnabled
            springStiffness = settings.springStiffness
            springDamping = settings.springDamping
            useSpringAnimations = settings.useSpringAnimations
            washLaunchEnabled = settings.washLaunchEnabled
            washLaunchScale = settings.washLaunchScale
            aiEnabled = settings.aiEnabled
            notificationPulseEnabled = settings.notificationPulseEnabled
            showNotificationPreview = settings.showNotificationPreview
            hoverBreachEnabled = settings.hoverBreachEnabled
            hoverBreachDelay = settings.hoverBreachDelay
            scrollToSelectEnabled = settings.scrollToSelectEnabled
            scrollSensitivity = settings.scrollSensitivity
            miniArcEnabled = settings.miniArcEnabled
            soundscapesEnabled = settings.soundscapesEnabled
            expansionSound = settings.expansionSound
            selectionSound = settings.selectionSound
            soundVolume = settings.soundVolume
            hapticProfilesEnabled = settings.hapticProfilesEnabled
            lightHapticWeight = settings.lightHapticWeight
            heavyHapticWeight = settings.heavyHapticWeight
            forgeEnabled = settings.forgeEnabled
            forgeScriptsPath = settings.forgeScriptsPath
            shortcutsIntegrationEnabled = settings.shortcutsIntegrationEnabled
            appMode = settings.appMode
            notchOverlayEnabled = settings.notchOverlayEnabled
            notchColor = settings.notchColor
            notchOpacity = settings.notchOpacity
            notchCornerRadius = settings.notchCornerRadius
            notchHeight = settings.notchHeight
            multiMonitorMode = settings.multiMonitorMode
            notchRenderMode = settings.notchRenderMode
            notchPreset = settings.notchPreset
            enableMultiMonitor = settings.enableMultiMonitor
            edgeToEdgeOpacity = settings.edgeToEdgeOpacity
            notchAnimationDuration = settings.notchAnimationDuration
            keyboardShortcutEnabled = settings.keyboardShortcutEnabled
            toggleNotchShortcut = settings.toggleNotchShortcut
            radialMenuEnabled = settings.radialMenuEnabled
            radialMenuMode = settings.radialMenuMode
            radialMenuRadius = settings.radialMenuRadius
            radialMenuItemSize = settings.radialMenuItemSize
            radialMenuAnimationStyle = settings.radialMenuAnimationStyle
            radialMenuShowLabels = settings.radialMenuShowLabels
            
            if let customSegments = persistence.loadCustomSegments() {
                arcSegments = customSegments
                hasCustomSegments = true
            }
            
            if let buttons = persistence.loadDockButtons() {
                dockButtons = buttons
            }
        }
        return success
    }
    
    func saveDockButtons() {
        persistence.saveDockButtons(dockButtons)
    }
    
    func addDockButton() {
        dockButtons.append(DockButton())
    }
    
    func removeDockButton(at index: Int) {
        guard index >= 0 && index < dockButtons.count else { return }
        dockButtons.remove(at: index)
    }
    
    func moveDockButton(from source: Int, to destination: Int) {
        guard source >= 0 && source < dockButtons.count,
              destination >= 0 && destination < dockButtons.count else { return }
        let button = dockButtons.remove(at: source)
        dockButtons.insert(button, at: destination)
    }
    
    func executeButtonAction(for button: DockButton) {
        switch button.actionType {
        case .settings:
            AppDelegate.shared.openSettings()
            
        case .app:
            if !button.actionValue.isEmpty {
                openApplication(bundleId: button.actionValue)
            }
            
        case .url:
            if !button.actionValue.isEmpty, let url = URL(string: button.actionValue) {
                NSWorkspace.shared.open(url)
            }
            
        case .folder:
            if !button.actionValue.isEmpty {
                NSWorkspace.shared.open(URL(fileURLWithPath: button.actionValue))
            }
            
        case .script:
            if !button.actionValue.isEmpty {
                runAppleScript(button.actionValue)
            }
            
        case .music:
            executeMusicAction(button.actionValue, service: button.musicService)
            
        case .note:
            AppDelegate.shared.openQuickNote()
            
        case .icon:
            break
            
        case .clipboard:
            handleClipboard()
        }
    }
    
    private func openApplication(bundleId: String) {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
        } else {
            print("Could not find app with bundle ID: \(bundleId)")
        }
    }
    
    func runAppleScript(_ script: String) {
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
    
    func handleClipboard() {
        let pasteboard = NSPasteboard.general
        if let clipboardString = pasteboard.string(forType: .string) {
            pasteboard.clearContents()
            pasteboard.setString(clipboardString, forType: .string)
        }
    }
    
    func executeMusicAction(_ action: String, service: DockButton.MusicService = .appleMusic) {
        let appName = service.appName
        
        let script: String
        switch action {
        case "playPause":
            script = "tell application \"\(appName)\" to playpause"
        case "next":
            script = "tell application \"\(appName)\" to next track"
        case "previous":
            script = "tell application \"\(appName)\" to previous track"
        case "volumeUp":
            script = "set volume output volume ((output volume of (get volume settings)) + 10)"
        case "volumeDown":
            script = "set volume output volume ((output volume of (get volume settings)) - 10)"
        case "mute":
            script = "set volume with output muted"
        default:
            script = "tell application \"\(appName)\" to playpause"
        }
        runAppleScript(script)
    }
}

enum AppMode: String, Codable {
    case minimal = "minimal"
    case productivity = "productivity"
}

enum NotchColor: String, Codable, CaseIterable {
    case black = "black"
    case darkGray = "darkGray"
    case auraInspired = "auraInspired"
    
    var color: NSColor {
        switch self {
        case .black: return .black
        case .darkGray: return NSColor(white: 0.2, alpha: 1.0)
        case .auraInspired: return NSColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        }
    }
}

enum MultiMonitorMode: String, Codable {
    case primaryOnly = "primary"
    case allMonitors = "all"
}

enum NotchRenderMode: String, Codable, CaseIterable {
    case notchOnly = "notchOnly"
    case edgeToEdge = "edgeToEdge"
    case hiddenNotch = "hidden"
    
    var displayName: String {
        switch self {
        case .notchOnly: return "Notch Only"
        case .edgeToEdge: return "Edge-to-Edge"
        case .hiddenNotch: return "Hidden"
        }
    }
}

enum NotchPreset: String, Codable, CaseIterable {
    case standard = "standard"
    case mini = "mini"
    case large = "large"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .mini: return "Mini"
        case .large: return "Large"
        case .custom: return "Custom"
        }
    }
}

enum RadialMenuMode: String, Codable, CaseIterable {
    case click = "click"
    case hover = "hover"
    case longPress = "longPress"
    
    var displayName: String {
        switch self {
        case .click: return "Click"
        case .hover: return "Hover"
        case .longPress: return "Long Press"
        }
    }
}

enum RadialAnimationStyle: String, Codable, CaseIterable {
    case spring = "spring"
    case easeOut = "easeOut"
    case bounce = "bounce"
    
    var displayName: String {
        self.rawValue.capitalized
    }
}
