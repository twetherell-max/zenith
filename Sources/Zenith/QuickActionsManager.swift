import AppKit
import Combine
import Foundation

struct RecentItem: Identifiable {
    let id = UUID()
    let name: String
    let path: URL
    let icon: NSImage?
    let date: Date?
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: QuickActionType
}

enum QuickActionType {
    case openFile(URL)
    case openFolder(URL)
    case openURL(String)
    case musicControl(String)
    case runScript(String)
    case copyToClipboard(String)
}

class QuickActionsManager: ObservableObject {
    static let shared = QuickActionsManager()
    
    @Published var recentItems: [RecentItem] = []
    @Published var isLoading = false
    
    private var cachedRecentItems: [String: [RecentItem]] = [:]
    
    private init() {}
    
    func getQuickActions(for button: DockButton) -> [QuickAction] {
        var actions: [QuickAction] = []
        
        switch button.actionType {
        case .app:
            if button.showRecentDocs || !button.pinnedItems.isEmpty {
                actions.append(contentsOf: getAppQuickActions(for: button))
            }
            
        case .folder:
            if !button.pinnedItems.isEmpty {
                actions.append(contentsOf: getFolderQuickActions(for: button))
            }
            
        case .music:
            actions.append(contentsOf: getMusicQuickActions())
            
        case .url:
            let url = button.actionValue
            if !url.isEmpty {
                actions.append(QuickAction(title: "Open", icon: "globe", action: .openURL(url)))
                actions.append(QuickAction(title: "Copy URL", icon: "doc.on.doc", action: .copyToClipboard(url)))
            }
            
        case .script:
            if !button.actionValue.isEmpty {
                actions.append(QuickAction(title: "Run", icon: "play.fill", action: .runScript(button.actionValue)))
            }
            
        case .note:
            actions.append(QuickAction(title: "New Note", icon: "plus", action: .openURL("zenith://new-note")))
            
        case .clipboard:
            actions.append(QuickAction(title: "Clear Clipboard", icon: "trash", action: .runScript("set the clipboard to \"\"")))
            
        default:
            break
        }
        
        return actions
    }
    
    private func getAppQuickActions(for button: DockButton) -> [QuickAction] {
        var actions: [QuickAction] = []
        
        for pinned in button.pinnedItems {
            let action: QuickActionType
            switch pinned.itemType {
            case .file:
                action = .openFile(URL(fileURLWithPath: pinned.path))
            case .folder:
                action = .openFolder(URL(fileURLWithPath: pinned.path))
            case .url:
                action = .openURL(pinned.path)
            }
            actions.append(QuickAction(title: pinned.name, icon: "pin.fill", action: action))
        }
        
        return actions
    }
    
    private func getFolderQuickActions(for button: DockButton) -> [QuickAction] {
        var actions: [QuickAction] = []
        
        for pinned in button.pinnedItems {
            let action: QuickActionType
            switch pinned.itemType {
            case .file:
                action = .openFile(URL(fileURLWithPath: pinned.path))
            case .folder:
                action = .openFolder(URL(fileURLWithPath: pinned.path))
            case .url:
                action = .openURL(pinned.path)
            }
            actions.append(QuickAction(title: pinned.name, icon: "pin.fill", action: action))
        }
        
        return actions
    }
    
    private func getMusicQuickActions() -> [QuickAction] {
        return [
            QuickAction(title: "Play/Pause", icon: "playpause.fill", action: .musicControl("playPause")),
            QuickAction(title: "Next", icon: "forward.fill", action: .musicControl("next")),
            QuickAction(title: "Previous", icon: "backward.fill", action: .musicControl("previous")),
            QuickAction(title: "Volume Up", icon: "speaker.plus", action: .musicControl("volumeUp")),
            QuickAction(title: "Volume Down", icon: "speaker.minus", action: .musicControl("volumeDown"))
        ]
    }
    
    func fetchRecentDocuments(for bundleId: String, limit: Int = 5) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        
        if let cached = cachedRecentItems[bundleId] {
            recentItems = Array(cached.prefix(limit))
            return
        }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let recents = self?.getRecentDocuments(for: appURL) ?? []
            
            DispatchQueue.main.async {
                self?.cachedRecentItems[bundleId] = recents
                self?.recentItems = Array(recents.prefix(limit))
                self?.isLoading = false
            }
        }
    }
    
    private func getRecentDocuments(for appURL: URL) -> [RecentItem] {
        let recentManager = NSDocumentController.shared
        var items: [RecentItem] = []
        
        let recentURLs = recentManager.recentDocumentURLs
        
        for url in recentURLs {
            let appInfo = NSWorkspace.shared.urlsForApplications(toOpen: url)
            if let firstApp = appInfo.first, firstApp.absoluteString.contains(appURL.absoluteString) {
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = NSSize(width: 32, height: 32)
                
                items.append(RecentItem(
                    name: url.lastPathComponent,
                    path: url,
                    icon: icon,
                    date: nil
                ))
            }
        }
        
        return items
    }
    
    func executeAction(_ action: QuickActionType) {
        switch action {
        case .openFile(let url):
            NSWorkspace.shared.open(url)
        case .openFolder(let url):
            NSWorkspace.shared.open(url)
        case .openURL(let urlString):
            if urlString.hasPrefix("zenith://") {
                handleZenithAction(urlString)
            } else if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        case .musicControl(let control):
            ZenithState.shared.executeMusicAction(control)
        case .runScript(let script):
            ZenithState.shared.runAppleScript(script)
        case .copyToClipboard(let text):
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        }
    }
    
    private func handleZenithAction(_ url: String) {
        switch url {
        case "zenith://new-note":
            AppDelegate.shared.openQuickNote()
        default:
            break
        }
    }
}
