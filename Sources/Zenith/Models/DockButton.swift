import Foundation

struct DockButton: Identifiable, Codable, Hashable {
    var id: UUID
    var icon: String
    var title: String
    var actionType: ActionType
    var actionValue: String
    var isEnabled: Bool
    
    enum ActionType: String, Codable, CaseIterable {
        case icon
        case app
        case folder
        case url
        case script
        case settings
        case music
        
        var displayName: String {
            switch self {
            case .icon: return "Icon Only"
            case .app: return "Open App"
            case .folder: return "Open Folder"
            case .url: return "Open URL"
            case .script: return "Run Script"
            case .settings: return "Open Settings"
            case .music: return "Music Control"
            }
        }
        
        var icon: String {
            switch self {
            case .icon: return "photo"
            case .app: return "app.badge"
            case .folder: return "folder"
            case .url: return "globe"
            case .script: return "terminal"
            case .settings: return "gearshape"
            case .music: return "music.note"
            }
        }
    }
    
    enum MusicAction: String, Codable, CaseIterable {
        case playPause
        case next
        case previous
        case volumeUp
        case volumeDown
        case mute
        
        var displayName: String {
            switch self {
            case .playPause: return "Play/Pause"
            case .next: return "Next Track"
            case .previous: return "Previous Track"
            case .volumeUp: return "Volume Up"
            case .volumeDown: return "Volume Down"
            case .mute: return "Mute/Unmute"
            }
        }
        
        var icon: String {
            switch self {
            case .playPause: return "play.fill"
            case .next: return "forward.fill"
            case .previous: return "backward.fill"
            case .volumeUp: return "speaker.plus"
            case .volumeDown: return "speaker.minus"
            case .mute: return "speaker.slash"
            }
        }
    }
    
    enum DockStyle: String, Codable, CaseIterable {
        case minimal
        case normal
        case bold
        case glow
        
        var displayName: String {
            rawValue.capitalized
        }
    }
    
    init(id: UUID = UUID(), icon: String = "⚙️", title: String = "Settings", actionType: ActionType = .icon, actionValue: String = "", isEnabled: Bool = true) {
        self.id = id
        self.icon = icon
        self.title = title
        self.actionType = actionType
        self.actionValue = actionValue
        self.isEnabled = isEnabled
    }
    
    static var defaultButtons: [DockButton] {
        [
            DockButton(icon: "🧭", title: "Compass", actionType: .icon, actionValue: ""),
            DockButton(icon: "📁", title: "Files", actionType: .folder, actionValue: "/Users/\(NSUserName())/Documents"),
            DockButton(icon: "⚙️", title: "Settings", actionType: .settings, actionValue: ""),
            DockButton(icon: "🎵", title: "Music", actionType: .music, actionValue: "playPause"),
            DockButton(icon: "📄", title: "Docs", actionType: .folder, actionValue: "/Users/\(NSUserName())/Documents"),
            DockButton(icon: "🌐", title: "Browser", actionType: .app, actionValue: "com.apple.Safari"),
            DockButton(icon: "📧", title: "Mail", actionType: .app, actionValue: "com.apple.Mail")
        ]
    }
}
