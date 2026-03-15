import SwiftUI
import Combine

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
    
    private init() {
        let storedArcSpread = UserDefaults.standard.double(forKey: "arcSpread")
        let storedDropDepth = UserDefaults.standard.double(forKey: "dropDepth")
        let storedIconSize = UserDefaults.standard.double(forKey: "iconSize")
        
        self.arcSpread = storedArcSpread == 0 ? 100.0 : storedArcSpread
        self.dropDepth = storedDropDepth == 0 ? 50.0 : storedDropDepth
        self.iconSize = storedIconSize == 0 ? 14.0 : storedIconSize
    }
}
