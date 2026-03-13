import AppKit

class ShortcutManager {
    static let shared = ShortcutManager()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    // Default shortcut: Cmd + Shift + Z
    func startMonitoring(onTrigger: @escaping () -> Void) {
        // Stop any existing monitoring
        stopMonitoring()
        
        // Monitor for global events (when app is in background)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.isShortcutMatch(event: event) == true {
                onTrigger()
            }
        }
        
        // Monitor for local events (when app is in foreground)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.isShortcutMatch(event: event) == true {
                onTrigger()
                return nil // Swallow the event
            }
            return event
        }
    }
    
    func stopMonitoring() {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }
    
    private func isShortcutMatch(event: NSEvent) -> Bool {
        // Cmd + Shift + Z
        // Z key code is 6
        let cmdPressed = event.modifierFlags.contains(.command)
        let shiftPressed = event.modifierFlags.contains(.shift)
        let zPressed = event.keyCode == 6
        
        return cmdPressed && shiftPressed && zPressed
    }
}
