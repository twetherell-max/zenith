import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let fileManager = FileManager.default
    private let appSupportDirectory: URL
    private let schemaVersion = 1
    
    private var customSegmentsFile: URL {
        appSupportDirectory.appendingPathComponent("custom_segments.json")
    }
    
    private var userSettingsFile: URL {
        appSupportDirectory.appendingPathComponent("user_settings.json")
    }
    
    private var dockButtonsFile: URL {
        appSupportDirectory.appendingPathComponent("dock_buttons.json")
    }
    
    private init() {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        appSupportDirectory = paths[0].appendingPathComponent("Zenith")
        
        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func backupCorruptedFile(at url: URL) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let backupURL = url.deletingPathExtension()
            .appendingPathExtension("backup.\(timestamp).json")
        try? fileManager.moveItem(at: url, to: backupURL)
        print("Backed up corrupted file to: \(backupURL.lastPathComponent)")
    }
    
    func saveCustomSegments(_ segments: [ArcSegment]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(segments)
            try data.write(to: customSegmentsFile)
        } catch {
            print("Failed to save custom segments: \(error)")
        }
    }
    
    func loadCustomSegments() -> [ArcSegment]? {
        guard fileManager.fileExists(atPath: customSegmentsFile.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: customSegmentsFile)
            let decoder = JSONDecoder()
            return try decoder.decode([ArcSegment].self, from: data)
        } catch {
            print("Failed to load custom segments: \(error)")
            backupCorruptedFile(at: customSegmentsFile)
            return nil
        }
    }
    
    func saveUserSettings(_ settings: UserSettings) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(settings)
            try data.write(to: userSettingsFile)
        } catch {
            print("Failed to save user settings: \(error)")
        }
    }
    
    func loadUserSettings() -> UserSettings {
        guard fileManager.fileExists(atPath: userSettingsFile.path) else {
            return UserSettings()
        }
        
        do {
            let data = try Data(contentsOf: userSettingsFile)
            let decoder = JSONDecoder()
            var settings = try decoder.decode(UserSettings.self, from: data)
            
            settings = migrateSettingsIfNeeded(settings)
            
            return settings
        } catch {
            print("Failed to load user settings: \(error)")
            backupCorruptedFile(at: userSettingsFile)
            return UserSettings()
        }
    }
    
    private func migrateSettingsIfNeeded(_ settings: UserSettings) -> UserSettings {
        return settings
    }
    
    func exportConfiguration() -> URL? {
        let export = ConfigurationExport(
            version: schemaVersion,
            settings: loadUserSettings(),
            customSegments: loadCustomSegments() ?? ArcSegment.defaultRoot,
            dockButtons: loadDockButtons() ?? DockButton.defaultButtons,
            exportDate: Date()
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(export)
            
            let tempDir = fileManager.temporaryDirectory
            let exportFile = tempDir.appendingPathComponent("zenith_export_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: exportFile)
            return exportFile
        } catch {
            print("Failed to export configuration: \(error)")
            return nil
        }
    }
    
    func importConfiguration(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let config = try decoder.decode(ConfigurationExport.self, from: data)
            
            saveUserSettings(config.settings)
            saveCustomSegments(config.customSegments)
            
            if let buttons = config.dockButtons {
                saveDockButtons(buttons)
            }
            
            return true
        } catch {
            print("Failed to import configuration: \(error)")
            return false
        }
    }
    
    func resetToDefaults() {
        try? fileManager.removeItem(at: customSegmentsFile)
        try? fileManager.removeItem(at: userSettingsFile)
        try? fileManager.removeItem(at: dockButtonsFile)
    }
    
    func saveDockButtons(_ buttons: [DockButton]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(buttons)
            try data.write(to: dockButtonsFile)
        } catch {
            print("Failed to save dock buttons: \(error)")
        }
    }
    
    func loadDockButtons() -> [DockButton]? {
        guard fileManager.fileExists(atPath: dockButtonsFile.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: dockButtonsFile)
            let decoder = JSONDecoder()
            return try decoder.decode([DockButton].self, from: data)
        } catch {
            print("Failed to load dock buttons: \(error)")
            backupCorruptedFile(at: dockButtonsFile)
            return nil
        }
    }
}

struct UserSettings: Codable {
    // Core Layout
    var barHeight: Double = 12.0
    var barOpacity: Double = 1.0
    var arcSpread: Double = 80.0
    var dropDepth: Double = 30.0
    var iconSize: Double = 14.0
    var isDarkGlass: Bool = false
    var buttonShape: ButtonShape = .rounded
    var accentColor: AccentColor = .white
    var contrastLevel: Double = 0.5
    var dockOpacity: Double = 0.8
    var hapticFeedback: Bool = true
    var autoShowDelay: Double = 0.1
    var hoverLift: Double = 6.0
    var borderWidth: Double = 1.0
    var notchWidth: Double = 150.0
    var dockStyle: DockButton.DockStyle = .normal
    
    // Focus Features
    var zenModeEnabled: Bool = false
    var focusDimmingEnabled: Bool = false
    
    // Animation
    var springStiffness: Double = 300.0
    var springDamping: Double = 20.0
    var useSpringAnimations: Bool = true
    var washLaunchEnabled: Bool = true
    var washLaunchScale: Double = 1.2
    
    // AI & Notifications
    var aiEnabled: Bool = false
    var notificationPulseEnabled: Bool = false
    var showNotificationPreview: Bool = true
    
    // Interaction
    var hoverBreachEnabled: Bool = true
    var hoverBreachDelay: Double = 0.2
    var scrollToSelectEnabled: Bool = false
    var scrollSensitivity: Double = 1.0
    var miniArcEnabled: Bool = true
    
    // Sound
    var soundscapesEnabled: Bool = false
    var expansionSound: Bool = true
    var selectionSound: Bool = true
    var soundVolume: Double = 0.5
    
    // Haptics
    var hapticProfilesEnabled: Bool = false
    var lightHapticWeight: Double = 0.5
    var heavyHapticWeight: Double = 1.0
    
    // Advanced
    var forgeEnabled: Bool = false
    var forgeScriptsPath: String = ""
    var shortcutsIntegrationEnabled: Bool = false
    
    // Minimal Notch Mode
    var appMode: AppMode = .productivity
    var notchOverlayEnabled: Bool = true
    var notchColor: NotchColor = .black
    var notchOpacity: Double = 1.0
    var notchCornerRadius: Double = 18.0
    var notchHeight: Double = 30.0
    var multiMonitorMode: MultiMonitorMode = .primaryOnly
}

enum ButtonShape: String, Codable, CaseIterable {
    case square
    case rounded
    case circle
    case pill
    
    var displayName: String {
        switch self {
        case .square: return "Square"
        case .rounded: return "Rounded"
        case .circle: return "Circle"
        case .pill: return "Pill"
        }
    }
}

enum AccentColor: String, Codable, CaseIterable {
    case white
    case blue
    case purple
    case pink
    case orange
    case green
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var colorValue: String {
        switch self {
        case .white: return "#FFFFFF"
        case .blue: return "#007AFF"
        case .purple: return "#AF52DE"
        case .pink: return "#FF2D55"
        case .orange: return "#FF9500"
        case .green: return "#34C759"
        }
    }
}

struct ConfigurationExport: Codable {
    let version: Int
    let settings: UserSettings
    let customSegments: [ArcSegment]
    let dockButtons: [DockButton]?
    let exportDate: Date
}
