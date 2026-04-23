import AppKit
import Carbon

class NotchShortcutManager {
    static let shared = NotchShortcutManager()
    
    private var eventMonitor: Any?
    private var isEnabled = false
    
    func setup() {
        let state = ZenithState.shared
        if state.keyboardShortcutEnabled {
            registerShortcut()
        }
        
        // Observe changes to shortcut settings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shortcutSettingsChanged),
            name: NSNotification.Name("notchShortcutChanged"),
            object: nil
        )
    }
    
    private func registerShortcut() {
        let state = ZenithState.shared
        
        // Parse shortcut string (e.g., "cmd+shift+n" -> flags + keyCode)
        let shortcut = state.toggleNotchShortcut.lowercased()
        
        guard let keyCode = parseKeyCode(shortcut),
              let flags = parseModifierFlags(shortcut) else {
            print(">>> Invalid shortcut: \(shortcut)")
            return
        }
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == keyCode && event.modifierFlags.contains(flags) {
                self?.handleShortcut()
            }
        }
        
        isEnabled = true
        print(">>> Notch keyboard shortcut registered: \(shortcut)")
    }
    
    @objc private func shortcutSettingsChanged() {
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
        
        let state = ZenithState.shared
        if state.keyboardShortcutEnabled {
            registerShortcut()
        }
    }
    
    private func handleShortcut() {
        let state = ZenithState.shared
        
        if state.appMode == .minimal {
            // Toggle notch visibility
            switch state.notchRenderMode {
            case .hiddenNotch:
                state.notchRenderMode = .notchOnly
            default:
                state.notchRenderMode = .hiddenNotch
            }
            
            // Haptic feedback
            NSFeedbackHelper().lightTap()
        }
    }
    
    private func parseKeyCode(_ shortcut: String) -> UInt16? {
        let parts = shortcut.split(separator: "+")
        guard let lastPart = parts.last else { return nil }
        
        let keyMap: [String: UInt16] = [
            "n": kVK_ANSI_N,
            "m": kVK_ANSI_M,
            "space": kVK_Space,
            "return": kVK_Return,
            "escape": kVK_Escape,
            "delete": kVK_Delete,
            "tab": kVK_Tab,
        ]
        
        return keyMap[String(lastPart)]
    }
    
    private func parseModifierFlags(_ shortcut: String) -> NSEvent.ModifierFlags? {
        let parts = shortcut.split(separator: "+").dropLast()
        var flags: NSEvent.ModifierFlags = []
        
        for part in parts {
            switch part.lowercased() {
            case "cmd": flags.insert(.command)
            case "shift": flags.insert(.shift)
            case "option", "alt": flags.insert(.option)
            case "control", "ctrl": flags.insert(.control)
            default: break
            }
        }
        
        return flags.isEmpty ? nil : flags
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
