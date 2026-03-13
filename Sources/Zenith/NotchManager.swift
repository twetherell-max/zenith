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
// ... remainder existing but we'll use findBuiltInScreen now

        // safeArea.top gives the height of the notch area (usually around 32-37px)
        // If there is no notch, safeArea.top might be 0 or equal to standard menu bar height.
        // On MacBook Pro with notch, safeArea.top is larger than 0.
        
        let notchHeight = safeArea.top
        if notchHeight <= 0 { return .zero }

        // Heuristic: The notch is centered and its width is typically around 180-200 points
        // on 14" and 16" MacBook Pros. safeAreaInsets doesn't provide width directly.
        // For a more robust solution, we use a standard width for the notch if one is detected.
        let estimatedWidth: CGFloat = 200 
        
        let x = (screenFrame.width - estimatedWidth) / 2
        let y = screenFrame.height - notchHeight
        
        return CGRect(x: x, y: y, width: estimatedWidth, height: notchHeight)
    }
}
