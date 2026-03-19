import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let fileManager = FileManager.default
    private let appSupportDirectory: URL
    
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
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
            print("Failed to load user settings: \(error)")
            return UserSettings()
        }
    }
    
    func exportConfiguration() -> URL? {
        let export = ConfigurationExport(
            version: 1,
            settings: loadUserSettings(),
            customSegments: loadCustomSegments() ?? ArcSegment.defaultRoot,
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
            return nil
        }
    }
}

struct UserSettings: Codable {
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
    let exportDate: Date
}
