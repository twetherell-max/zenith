import SwiftUI
import Combine
import Foundation

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
    
    @Published var isSettingsOpen: Bool = false
    @Published var isExpanded: Bool = false
    
    // DEBUG ID: If you see two different numbers, there are two windows.
    let debugID = Int.random(in: 1...100)
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private init() {
        self.arcSpread = UserDefaults.standard.double(forKey: "arcSpread") == 0 ? 80.0 : UserDefaults.standard.double(forKey: "arcSpread")
        self.dropDepth = UserDefaults.standard.double(forKey: "dropDepth") == 0 ? 50.0 : UserDefaults.standard.double(forKey: "dropDepth")
        self.iconSize = UserDefaults.standard.double(forKey: "iconSize") == 0 ? 14.0 : UserDefaults.standard.double(forKey: "iconSize")
    }
}
