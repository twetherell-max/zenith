import Foundation

struct RadialMenuItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var icon: String
    var actionType: ActionType
    var actionValue: String
    var isEnabled: Bool
    var color: String

    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        actionType: ActionType,
        actionValue: String = "",
        isEnabled: Bool = true,
        color: String = "#FFFFFF"
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.actionType = actionType
        self.actionValue = actionValue
        self.isEnabled = isEnabled
        self.color = color
    }

    enum ActionType: String, Codable, CaseIterable {
        case app
        case folder
        case url
        case script
        case music
        case settings
        case search
        case clipboard

        var displayName: String {
            switch self {
            case .app: return "Open App"
            case .folder: return "Open Folder"
            case .url: return "Open URL"
            case .script: return "Run Script"
            case .music: return "Music Control"
            case .settings: return "Open Settings"
            case .search: return "Search"
            case .clipboard: return "Clipboard"
            }
        }

        var systemIcon: String {
            switch self {
            case .app: return "app.badge"
            case .folder: return "folder"
            case .url: return "globe"
            case .script: return "terminal"
            case .music: return "music.note"
            case .settings: return "gearshape"
            case .search: return "magnifyingglass"
            case .clipboard: return "doc.on.clipboard"
            }
        }
    }

    static var defaultItems: [RadialMenuItem] {
        [
            RadialMenuItem(title: "Settings", icon: "⚙️", actionType: .settings, color: "#8E8E93"),
            RadialMenuItem(title: "Finder", icon: "📁", actionType: .folder, actionValue: NSHomeDirectory(), color: "#007AFF"),
            RadialMenuItem(title: "Music", icon: "🎵", actionType: .music, actionValue: "playPause", color: "#FF2D55"),
            RadialMenuItem(title: "Safari", icon: "🌐", actionType: .app, actionValue: "com.apple.Safari", color: "#34C759"),
            RadialMenuItem(title: "Search", icon: "🔍", actionType: .search, color: "#FF9500"),
            RadialMenuItem(title: "Clipboard", icon: "📋", actionType: .clipboard, color: "#AF52DE"),
        ]
    }
}
