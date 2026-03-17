import SwiftUI
import Combine
import Foundation
import AppKit

class ZenithState: ObservableObject {
    static let shared = ZenithState()
    
    @Published var arcSpread: Double {
        didSet { UserDefaults.standard.set(arcSpread, forKey: "arcSpread") }
    }
    
    @Published var dropDepth: Double {
        didSet { UserDefaults.standard.set(dropDepth, forKey: "dropDepth") }
    }
    
    @Published var iconSize: Double {
        didSet { UserDefaults.standard.set(iconSize, forKey: "iconSize") }
    }
    
    @Published var isDarkGlass: Bool {
        didSet { UserDefaults.standard.set(isDarkGlass, forKey: "isDarkGlass") }
    }
    
    @Published var isSettingsOpen: Bool = false
    @Published var isExpanded: Bool = false
    
    // Arc Level System
    @Published var currentLevel: Int = 1
    @Published var expandedCategoryId: UUID?
    @Published var arcSegments: [ArcSegment] = ArcSegment.defaultRoot
    
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
        self.arcSpread = UserDefaults.standard.double(forKey: "arcSpread") == 0 ? 80.0 : UserDefaults.standard.double(forKey: "arcSpread")
        self.dropDepth = UserDefaults.standard.double(forKey: "dropDepth") == 0 ? 30.0 : UserDefaults.standard.double(forKey: "dropDepth")
        self.iconSize = UserDefaults.standard.double(forKey: "iconSize") == 0 ? 14.0 : UserDefaults.standard.double(forKey: "iconSize")
        self.isDarkGlass = UserDefaults.standard.bool(forKey: "isDarkGlass")
    }
}
