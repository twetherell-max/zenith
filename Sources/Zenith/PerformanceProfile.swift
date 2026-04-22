import Foundation

struct PerformanceProfile {
    enum Mode {
        case minimal
        case productivity
    }
    
    static func configure(for mode: Mode) {
        switch mode {
        case .minimal:
            // Disable expensive animations
            ZenithState.shared.useSpringAnimations = false
            ZenithState.shared.hapticFeedback = false
            
        case .productivity:
            // Restore animations
            ZenithState.shared.useSpringAnimations = true
        }
    }
}
