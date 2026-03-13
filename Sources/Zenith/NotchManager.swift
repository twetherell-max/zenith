import AppKit

class NotchManager {
    static let shared = NotchManager()

    func findBuiltInScreen() -> NSScreen? {
        // Search all screens for the one with top safe area insets (the notch)
        let screens = NSScreen.screens
        for screen in screens {
            if screen.safeAreaInsets.top > 0 {
                return screen
            }
        }
        // Fallback to main screen if no notch-screen detected
        return NSScreen.main
    }

    var notchFrame: CGRect {
        guard let screen = findBuiltInScreen() else { return .zero }
        let safeArea = screen.safeAreaInsets
        let screenFrame = screen.frame
        
        // Standard MacBook Notch is approx 200px wide. 
        // We use the safeArea.top to determine the height.
        let notchWidth: CGFloat = 200
        let notchHeight = safeArea.top > 0 ? safeArea.top : 37
        
        let x = screenFrame.origin.x + (screenFrame.width - notchWidth) / 2
        let y = screenFrame.origin.y + screenFrame.height - notchHeight
        
        return CGRect(x: x, y: y, width: notchWidth, height: notchHeight)
    }
}
