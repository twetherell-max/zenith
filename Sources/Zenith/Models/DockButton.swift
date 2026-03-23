import Foundation

struct DockButton: Identifiable, Codable, Hashable {
    var id: UUID
    var icon: String
    var title: String
    var actionType: ActionType
    var actionValue: String
    var musicService: MusicService
    var isEnabled: Bool
    
    // Quick Actions
    var quickActionsEnabled: Bool = false
    var quickActionTrigger: QuickActionTrigger = .hover
    var quickActionDelay: Double = 0.5
    var pinnedItems: [PinnedItem] = []
    var showRecentDocs: Bool = false
    
    enum ActionType: String, Codable, CaseIterable {
        case icon
        case app
        case folder
        case url
        case script
        case settings
        case music
        case note
        case clipboard
        
        var displayName: String {
            switch self {
            case .icon: return "Icon Only"
            case .app: return "Open App"
            case .folder: return "Open Folder"
            case .url: return "Open URL"
            case .script: return "Run Script"
            case .settings: return "Open Settings"
            case .music: return "Music Control"
            case .note: return "Quick Note"
            case .clipboard: return "Clipboard"
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
            case .note: return "note.text"
            case .clipboard: return "doc.on.clipboard"
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
    
    enum MusicService: String, Codable, CaseIterable {
        case appleMusic
        case spotify
        
        var displayName: String {
            switch self {
            case .appleMusic: return "Apple Music"
            case .spotify: return "Spotify"
            }
        }
        
        var appName: String {
            switch self {
            case .appleMusic: return "Music"
            case .spotify: return "Spotify"
            }
        }
    }
    
    enum MusicDisplayMode: String, Codable, CaseIterable {
        case icon
        case artwork
        case popup
        
        var displayName: String {
            switch self {
            case .icon: return "Icon"
            case .artwork: return "Album Art"
            case .popup: return "Popup"
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
    
    enum DockLayout: String, Codable, CaseIterable {
        case radial
        case list
        
        var displayName: String {
            switch self {
            case .radial: return "Radial Arc"
            case .list: return "Horizontal List"
            }
        }
    }
    
    enum QuickActionTrigger: String, Codable, CaseIterable {
        case hover
        case doubleClick
        
        var displayName: String {
            switch self {
            case .hover: return "Hover"
            case .doubleClick: return "Double Click"
            }
        }
    }
    
    enum PinnedItemType: String, Codable {
        case file
        case folder
        case url
    }
    
    struct PinnedItem: Codable, Identifiable, Hashable {
        let id: UUID
        var name: String
        var path: String
        var itemType: PinnedItemType
        
        init(id: UUID = UUID(), name: String, path: String, itemType: PinnedItemType) {
            self.id = id
            self.name = name
            self.path = path
            self.itemType = itemType
        }
    }
    
    struct PresetIcon: Identifiable, Hashable {
        let id = UUID()
        let emoji: String
        let name: String
        let type: ActionType
        var value: String = ""
        var musicService: MusicService = .appleMusic
        
        var button: DockButton {
            DockButton(icon: emoji, title: name, actionType: type, actionValue: value, musicService: musicService)
        }
    }
    
    static let presetIcons: [PresetIcon] = [
        PresetIcon(emoji: "📁", name: "Documents", type: .folder, value: "/Users/\(NSUserName())/Documents"),
        PresetIcon(emoji: "📥", name: "Downloads", type: .folder, value: "/Users/\(NSUserName())/Downloads"),
        PresetIcon(emoji: "🖥️", name: "Desktop", type: .folder, value: "/Users/\(NSUserName())/Desktop"),
        PresetIcon(emoji: "📄", name: "Notes", type: .app, value: "com.apple.Notes"),
        PresetIcon(emoji: "📅", name: "Calendar", type: .app, value: "com.apple.Calendar"),
        PresetIcon(emoji: "📧", name: "Mail", type: .app, value: "com.apple.Mail"),
        PresetIcon(emoji: "💬", name: "Messages", type: .app, value: "com.apple.MobileSMS"),
        PresetIcon(emoji: "📹", name: "FaceTime", type: .app, value: "com.apple.FaceTime"),
        PresetIcon(emoji: "🎵", name: "Music", type: .music),
        PresetIcon(emoji: "🎬", name: "TV", type: .app, value: "com.apple.TV"),
        PresetIcon(emoji: "🎮", name: "Arcade", type: .app, value: "com.apple.GameCenter"),
        PresetIcon(emoji: "⚙️", name: "Settings", type: .settings),
        PresetIcon(emoji: "🧭", name: "Compass", type: .icon),
        PresetIcon(emoji: "🌐", name: "Safari", type: .app, value: "com.apple.Safari"),
        PresetIcon(emoji: "🖥️", name: "Terminal", type: .app, value: "com.apple.Terminal"),
        PresetIcon(emoji: "📋", name: "Clipboard", type: .clipboard),
        PresetIcon(emoji: "🔒", name: "Lock Screen", type: .script, value: "pmset displaysleepnow"),
        PresetIcon(emoji: "📸", name: "Screenshot", type: .script, value: "screencapture -x"),
        PresetIcon(emoji: "🔊", name: "Volume Up", type: .script, value: "set volume output volume ((output volume of (get volume settings)) + 10)"),
        PresetIcon(emoji: "🔉", name: "Volume Down", type: .script, value: "set volume output volume ((output volume of (get volume settings)) - 10)"),
        PresetIcon(emoji: "🎵", name: "Apple Music", type: .music, value: "playPause"),
        PresetIcon(emoji: "🎧", name: "Spotify", type: .music, value: "playPause"),
        PresetIcon(emoji: "📝", name: "Quick Note", type: .note),
        PresetIcon(emoji: "🌙", name: "Sleep", type: .script, value: "pmset displaysleepnow"),
        PresetIcon(emoji: "🔁", name: "Restart", type: .script, value: "tell app \"System Events\" to restart"),
    ]
    
    init(id: UUID = UUID(), icon: String = "⚙️", title: String = "Settings", actionType: ActionType = .icon, actionValue: String = "", musicService: MusicService = .appleMusic, isEnabled: Bool = true) {
        self.id = id
        self.icon = icon
        self.title = title
        self.actionType = actionType
        self.actionValue = actionValue
        self.musicService = musicService
        self.isEnabled = isEnabled
    }
    
    static var defaultButtons: [DockButton] {
        [
            DockButton(icon: "🧭", title: "Compass", actionType: .icon, actionValue: ""),
            DockButton(icon: "📁", title: "Documents", actionType: .folder, actionValue: "/Users/\(NSUserName())/Documents"),
            DockButton(icon: "⚙️", title: "Settings", actionType: .settings, actionValue: ""),
            DockButton(icon: "🎵", title: "Music", actionType: .music, actionValue: "playPause"),
            DockButton(icon: "📄", title: "Notes", actionType: .app, actionValue: "com.apple.Notes"),
            DockButton(icon: "🌐", title: "Safari", actionType: .app, actionValue: "com.apple.Safari"),
            DockButton(icon: "📧", title: "Mail", actionType: .app, actionValue: "com.apple.Mail")
        ]
    }
}
