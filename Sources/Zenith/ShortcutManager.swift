import AppKit

class ShortcutManager {
    static let shared = ShortcutManager()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    enum ShortcutType {
        case toggle
        case pulse
    }
    
    func startMonitoring(onTrigger: @escaping (ShortcutType) -> Void) {
        stopMonitoring()
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let type = self?.matchShortcut(event: event) {
                onTrigger(type)
            }
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let type = self?.matchShortcut(event: event) {
                onTrigger(type)
                return nil
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
    
    private func matchShortcut(event: NSEvent) -> ShortcutType? {
        let cmdPressed = event.modifierFlags.contains(.command)
        let shiftPressed = event.modifierFlags.contains(.shift)
        
        // Z key code is 6 (Cmd+Shift+Z)
        if cmdPressed && shiftPressed && event.keyCode == 6 {
            return .toggle
        }
        
        // J key code is 38 (Cmd+Shift+J)
        if cmdPressed && shiftPressed && event.keyCode == 38 {
            return .pulse
        }
        
        return nil
    }
}
