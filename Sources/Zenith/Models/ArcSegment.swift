import Foundation

struct ArcSegment: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    var level: Int
    var isCategory: Bool
    var children: [ArcSegment]?
    var action: String?
    var actionType: ActionType
    
    enum ActionType: String, Codable {
        case app
        case folder
        case media
        case settings
        case clipboard
        case none
    }
    
    init(id: UUID = UUID(), title: String, icon: String, level: Int, isCategory: Bool, children: [ArcSegment]? = nil, action: String? = nil, actionType: ActionType = .none) {
        self.id = id
        self.title = title
        self.icon = icon
        self.level = level
        self.isCategory = isCategory
        self.children = children
        self.action = action
        self.actionType = actionType
    }
    
    static var defaultRoot: [ArcSegment] {
        [
            ArcSegment(
                id: UUID(),
                title: "Quick Apps",
                icon: "app.badge",
                level: 1,
                isCategory: true,
                children: [
                    ArcSegment(id: UUID(), title: "Chrome", icon: "globe", level: 2, isCategory: true, children: [
                        ArcSegment(id: UUID(), title: "Account 1", icon: "person", level: 3, isCategory: false, action: "com.google.Chrome", actionType: .app),
                        ArcSegment(id: UUID(), title: "Account 2", icon: "person", level: 3, isCategory: false, action: "com.google.Chrome", actionType: .app)
                    ]),
                    ArcSegment(id: UUID(), title: "Safari", icon: "safari", level: 2, isCategory: false, action: "com.apple.Safari", actionType: .app),
                    ArcSegment(id: UUID(), title: "VS Code", icon: "chevron.left.forwardslash.chevron.right", level: 2, isCategory: false, action: "com.microsoft.VSCode", actionType: .app)
                ]
            ),
            ArcSegment(
                id: UUID(),
                title: "Music",
                icon: "music.note",
                level: 1,
                isCategory: true,
                children: [
                    ArcSegment(id: UUID(), title: "Play/Pause", icon: "playpause.fill", level: 2, isCategory: false, action: "media-playpause", actionType: .media),
                    ArcSegment(id: UUID(), title: "Next", icon: "forward.fill", level: 2, isCategory: false, action: "media-next", actionType: .media),
                    ArcSegment(id: UUID(), title: "Previous", icon: "backward.fill", level: 2, isCategory: false, action: "media-previous", actionType: .media)
                ]
            ),
            ArcSegment(
                id: UUID(),
                title: "Folders",
                icon: "folder.fill",
                level: 1,
                isCategory: true,
                children: [
                    ArcSegment(id: UUID(), title: "Downloads", icon: "arrow.down.circle", level: 2, isCategory: false, action: "downloads", actionType: .folder),
                    ArcSegment(id: UUID(), title: "Documents", icon: "doc.fill", level: 2, isCategory: false, action: "documents", actionType: .folder),
                    ArcSegment(id: UUID(), title: "Desktop", icon: "desktopcomputer", level: 2, isCategory: false, action: "desktop", actionType: .folder)
                ]
            ),
            ArcSegment(
                id: UUID(),
                title: "Settings",
                icon: "gearshape.fill",
                level: 1,
                isCategory: false,
                action: "settings",
                actionType: .settings
            )
        ]
    }
}
