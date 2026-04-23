import Foundation
import AppKit

struct RadialMenuItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var actionType: ActionType
    var actionValue: String
    var isEnabled: Bool = true
    var color: MenuItemColor = .auto
    
    enum ActionType: String, Codable, CaseIterable {
        case app = "app"
        case folder = "folder"
        case url = "url"
        case script = "script"
        case music = "music"
        case settings = "settings"
        case search = "search"
        case clipboard = "clipboard"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .app: return "Application"
            case .folder: return "Folder"
            case .url: return "Website"
            case .script: return "AppleScript"
            case .music: return "Music Control"
            case .settings: return "Settings"
            case .search: return "Search"
            case .clipboard: return "Clipboard"
            case .custom: return "Custom"
            }
        }
        
        var icon: String {
            switch self {
            case .app: return "app.fill"
            case .folder: return "folder.fill"
            case .url: return "globe"
            case .script: return "terminal.fill"
            case .music: return "music.note"
            case .settings: return "gearshape.fill"
            case .search: return "magnifyingglass"
            case .clipboard: return "doc.on.clipboard"
            case .custom: return "star.fill"
            }
        }
    }
    
    enum MenuItemColor: String, Codable, CaseIterable {
        case auto = "auto"
        case white = "white"
        case blue = "blue"
        case red = "red"
        case green = "green"
        case orange = "orange"
        case purple = "purple"
        case pink = "pink"
        
        var displayName: String {
            self.rawValue.capitalized
        }
        
        var nsColor: NSColor {
            switch self {
            case .auto: return .orange
            case .white: return .white
            case .blue: return .systemBlue
            case .red: return .systemRed
            case .green: return .systemGreen
            case .orange: return .systemOrange
            case .purple: return .systemPurple
            case .pink: return .systemPink
            }
        }
    }
    
    init(title: String = "", icon: String = "star", actionType: ActionType = .custom) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.actionType = actionType
        self.actionValue = ""
    }
}

// Default menu items
extension RadialMenuItem {
    static var defaults: [RadialMenuItem] {
        [
            RadialMenuItem(title: "Settings", icon: "gearshape.fill", actionType: .settings),
            RadialMenuItem(title: "Finder", icon: "folder.fill", actionType: .app),
            RadialMenuItem(title: "Safari", icon: "globe", actionType: .app),
            RadialMenuItem(title: "Music", icon: "music.note", actionType: .music),
            RadialMenuItem(title: "Search", icon: "magnifyingglass", actionType: .search),
        ]
    }
}
