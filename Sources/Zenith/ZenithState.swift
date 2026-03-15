import SwiftUI
import Combine

class ZenithState: ObservableObject {
    static let shared = ZenithState()
    
    @AppStorage("arcSpread") var arcSpread: Double = 80.0
    @AppStorage("dropDepth") var dropDepth: Double = 50.0
    @AppStorage("iconSize") var iconSize: Double = 14.0
    
    private init() {}
}
