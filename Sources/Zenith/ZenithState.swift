import SwiftUI
import Combine
import Foundation

// 1. GLOBAL MEMORY RESET: ENSURE ABSOLUTE CROSS-WINDOW TRUTH
private var GLOBAL_ARC_SPREAD: Double = UserDefaults.standard.double(forKey: "arcSpread") == 0 ? 80.0 : UserDefaults.standard.double(forKey: "arcSpread")
private var GLOBAL_DROP_DEPTH: Double = UserDefaults.standard.double(forKey: "dropDepth") == 0 ? 50.0 : UserDefaults.standard.double(forKey: "dropDepth")
private var GLOBAL_ICON_SIZE: Double = UserDefaults.standard.double(forKey: "iconSize") == 0 ? 14.0 : UserDefaults.standard.double(forKey: "iconSize")

class ZenithState: ObservableObject {
    static let shared = ZenithState()
    
    var arcSpread: Double {
        get { GLOBAL_ARC_SPREAD }
        set {
            GLOBAL_ARC_SPREAD = newValue
            UserDefaults.standard.set(newValue, forKey: "arcSpread")
            objectWillChange.send()
        }
    }
    
    var dropDepth: Double {
        get { GLOBAL_DROP_DEPTH }
        set {
            GLOBAL_DROP_DEPTH = newValue
            UserDefaults.standard.set(newValue, forKey: "dropDepth")
            objectWillChange.send()
        }
    }
    
    var iconSize: Double {
        get { GLOBAL_ICON_SIZE }
        set {
            GLOBAL_ICON_SIZE = newValue
            UserDefaults.standard.set(newValue, forKey: "iconSize")
            objectWillChange.send()
        }
    }
    
    @Published var isSettingsOpen: Bool = false
    @Published var isExpanded: Bool = false
    
    // DEBUG ID: If you see two different numbers, there are two windows.
    private let debugID = Int.random(in: 1...100)
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private init() {}
}
