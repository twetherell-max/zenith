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
        UserDefaults.standard.register(defaults: [
            "arcSpread": 80.0,
            "dropDepth": 40.0,
            "iconSize": 14.0
        ])
        
        let storedArcSpread = UserDefaults.standard.double(forKey: "arcSpread")
        let storedDropDepth = UserDefaults.standard.double(forKey: "dropDepth")
        let storedIconSize = UserDefaults.standard.double(forKey: "iconSize")
        
        self.arcSpread = storedArcSpread == 0 ? 80.0 : storedArcSpread
        self.dropDepth = storedDropDepth == 0 ? 40.0 : storedDropDepth
        self.iconSize = storedIconSize == 0 ? 14.0 : storedIconSize
    }
    
    func load() {
        let storedArcSpread = UserDefaults.standard.double(forKey: "arcSpread")
        let storedDropDepth = UserDefaults.standard.double(forKey: "dropDepth")
        let storedIconSize = UserDefaults.standard.double(forKey: "iconSize")
        
        self.arcSpread = storedArcSpread == 0 ? 80.0 : storedArcSpread
        self.dropDepth = storedDropDepth == 0 ? 40.0 : storedDropDepth
        self.iconSize = storedIconSize == 0 ? 14.0 : storedIconSize
    }
}
