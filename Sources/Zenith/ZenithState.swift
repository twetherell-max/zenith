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
    
    @Published var isSettingsOpen: Bool = false
    @Published var isExpanded: Bool = false
    
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
        
        if let customSegments = persistence.loadCustomSegments() {
            self.arcSegments = customSegments
            self.hasCustomSegments = true
        } else {
            self.arcSegments = ArcSegment.defaultRoot
        }
    }
    
    private func saveSettings() {
        let settings = UserSettings(
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
            dockStyle: dockStyle
        )
        persistence.saveUserSettings(settings)
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
            
            if let customSegments = persistence.loadCustomSegments() {
                arcSegments = customSegments
                hasCustomSegments = true
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
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        case .app:
            if !button.actionValue.isEmpty {
                NSWorkspace.shared.open(URL(string: "zenith://open-app/\(button.actionValue)")!)
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
                var error: NSDictionary?
                if let script = NSAppleScript(source: button.actionValue) {
                    script.executeAndReturnError(&error)
                }
            }
        case .icon:
            break
        case .music:
            executeMusicAction(button.actionValue)
        }
    }
    
    func executeMusicAction(_ action: String) {
        let script: String
        switch action {
        case "playPause":
            script = "tell application \"Music\" to playpause"
        case "next":
            script = "tell application \"Music\" to next track"
        case "previous":
            script = "tell application \"Music\" to previous track"
        case "volumeUp":
            script = "set volume output volume ((output volume of (get volume settings)) + 10)"
        case "volumeDown":
            script = "set volume output volume ((output volume of (get volume settings)) - 10)"
        case "mute":
            script = "set volume with output muted"
        default:
            script = "tell application \"Music\" to playpause"
        }
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
}
