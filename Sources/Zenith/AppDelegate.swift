import AppKit
import SwiftUI
import WebKit

class RadialDockContainerView: NSView {
    weak var webView: WKWebView?
    var mouseTimer: Timer?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        webView?.evaluateJavaScript("setExpanded(true)") { _, _ in }
    }
    
    override func mouseExited(with event: NSEvent) {
        webView?.evaluateJavaScript("setExpanded(false)") { _, _ in }
    }
    
    func startMouseTracking() {
        var wasInNotch = false
        mouseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let webView = self.webView, let window = self.window else { return }
            let mouseLoc = NSEvent.mouseLocation
            let windowLoc = window.convertPoint(fromScreen: mouseLoc)
            let localLoc = self.convert(windowLoc, from: nil)
            
            // Check if mouse is in notch area OR dock area (top center area)
            let hoverArea = NSRect(x: self.bounds.width/2 - 120, y: self.bounds.height - 180, width: 240, height: 180)
            let isInHoverArea = hoverArea.contains(localLoc)
            
            if isInHoverArea && !wasInNotch {
                wasInNotch = true
                webView.evaluateJavaScript("setExpanded(true)") { _, _ in }
            } else if !isInHoverArea && wasInNotch {
                wasInNotch = false
                webView.evaluateJavaScript("setExpanded(false)") { _, _ in }
            }
        }
    }
}

class RadialDockCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    var settingsCheckTimer: Timer?
    
    override init() {
        super.init()
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "radialDock",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }
        
        print(">>> Received message: \(type)")
        
        if type == "openSettings" {
            print(">>> Opening settings via shared...")
            print(">>> AppDelegate.shared: \(AppDelegate.shared)")
            AppDelegate.shared?.openSettings()
        } else if type == "checkSettings" {
            DispatchQueue.main.async { [weak self] in
                let isOpen = NSApp.windows.contains { $0.title == "Zenith Settings" && $0.isVisible }
                self?.webView?.evaluateJavaScript("setPreviewMode(\(isOpen))") { _, _ in }
            }
        } else if type == "buttonClick" {
            if let actionType = body["actionType"] as? String,
               let actionValue = body["actionValue"] as? String {
                DispatchQueue.main.async {
                    self.handleButtonAction(type: actionType, value: actionValue)
                }
            }
        }
    }
    
    private func handleButtonAction(type: String, value: String) {
        switch type {
        case "settings":
            AppDelegate.shared?.openSettings()
        case "app":
            if !value.isEmpty {
                NSWorkspace.shared.open(URL(string: value)!)
            }
        case "url":
            if !value.isEmpty, let url = URL(string: value) {
                NSWorkspace.shared.open(url)
            }
        case "folder":
            if !value.isEmpty {
                NSWorkspace.shared.open(URL(fileURLWithPath: value))
            }
        case "script":
            if !value.isEmpty {
                var error: NSDictionary?
                if let script = NSAppleScript(source: value) {
                    script.executeAndReturnError(&error)
                }
            }
        default:
            break
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    
    var statusItem: NSStatusItem?
    var zenithWindow: ZenithWindow?
    var settingsWindow: NSWindow?
    var dockCoordinator: RadialDockCoordinator?
    var zenitSettingsWindow: NSWindow?
    
    func openSettings() {
        print(">>> openSettings called")
        
        if zenitSettingsWindow == nil {
            print(">>> Creating settings window")
            
            let settingsView = ZenithSettingsView()
            let hostingView = NSHostingView(rootView: settingsView)
            hostingView.frame = NSRect(x: 0, y: 0, width: 450, height: 600)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.contentView = hostingView
            window.title = "Zenith Settings"
            window.isReleasedWhenClosed = false
            window.center()
            window.level = .floating
            
            zenitSettingsWindow = window
        }
        
        zenitSettingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func syncDockSettings() {
        let state = ZenithState.shared
        let accentColors: [String: String] = [
            "white": "#FFFFFF",
            "blue": "#007AFF",
            "purple": "#AF52DE",
            "pink": "#FF2D55",
            "orange": "#FF9500",
            "green": "#34C759"
        ]
        let color = accentColors[state.accentColor.rawValue] ?? "#FFFFFF"
        
        let settingsJson = """
        {
            "buttonShape": "\(state.buttonShape.rawValue)",
            "accentColor": "\(color)",
            "iconSize": \(state.iconSize),
            "opacity": \(state.dockOpacity * 0.15),
            "contrast": \(state.contrastLevel * 0.3),
            "arcSpread": \(state.arcSpread),
            "dropDepth": \(state.dropDepth),
            "hoverLift": \(state.hoverLift),
            "borderWidth": \(state.borderWidth),
            "notchWidth": \(state.notchWidth),
            "dockStyle": "\(state.dockStyle.rawValue)"
        }
        """
        
        dockCoordinator?.webView?.evaluateJavaScript("updateSettings(\(settingsJson))") { _, _ in }
        
        let buttonsJson = dockButtonsToJson()
        dockCoordinator?.webView?.evaluateJavaScript("updateButtons(\(buttonsJson))") { _, _ in }
    }
    
    private func dockButtonsToJson() -> String {
        let state = ZenithState.shared
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(state.dockButtons),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }
    
    // Explicit access to state for injection
    let state = ZenithState.shared
    
    private func createZIcon() -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size, flipped: false) { rect in
            let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: 1, dy: 1))
            NSColor.white.withAlphaComponent(0.3).setFill()
            circlePath.fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: NSColor.white
            ]
            let zString = "Z"
            let textSize = zString.size(withAttributes: attributes)
            let textRect = NSRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            zString.draw(in: textRect, withAttributes: attributes)
            return true
        }
        image.isTemplate = false
        return image
    }
 
    override init() {
        super.init()
        AppDelegate.shared = self
        print(">>> AppDelegate initialized")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // THE SHARED LINK - ABSOLUTE FIRST LINE
        AppDelegate.shared = self
        
        // Safety: ensure activation policy is correct
        NSApp.setActivationPolicy(.regular)
        
        // Kill ghosts
        NSApp.disableRelaunchOnLogin()
        
        // FORCE MENU BAR
        setupStatusItem()

        if self.zenithWindow == nil {
            print(">>> Creating Zenith Window...")
            
            let screen = NotchManager.shared.findBuiltInScreen() ?? NSScreen.main ?? NSScreen.screens[0]
            let screenWidth = screen.frame.width
            let safeTop = screen.safeAreaInsets.top
            let notchFrame = NotchManager.shared.notchFrame
            
            print(">>> Screen: \(screenWidth), safeTop: \(safeTop)")
            print(">>> Notch: \(notchFrame)")
            print(">>> Visible frame: \(screen.visibleFrame)")
            
            // Use a compact top-floating window so it sits high under menu bar
            let windowHeight: CGFloat = 260
            let windowWidth: CGFloat = 800

            // Position at the top of visible frame
            let windowY = screen.visibleFrame.origin.y + screen.visibleFrame.height - 40
            let windowX = (screen.frame.width - windowWidth) / 2

            print(">>> Window X: \(windowX), Y: \(windowY)")

            let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)
            
            let window = NSWindow(
                contentRect: windowFrame,
                styleMask: NSWindow.StyleMask.borderless,
                backing: NSWindow.BackingStoreType.buffered,
                defer: false
            )
            
            window.backgroundColor = NSColor.clear
            window.isOpaque = false
            window.ignoresMouseEvents = false
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.hasShadow = false
            window.isRestorable = false
            window.isReleasedWhenClosed = false
            
            print(">>> Window frame: \(window.frame)")
            print(">>> Screen: \(screen.frame)")
            
            // Create WebView container
            let containerView = RadialDockContainerView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
            containerView.wantsLayer = true
            
            // Create WKWebView directly
            let config = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            self.dockCoordinator = RadialDockCoordinator()
            userContentController.add(self.dockCoordinator!, name: "radialDock")
            config.userContentController = userContentController
            
            let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight), configuration: config)
            webView.navigationDelegate = self.dockCoordinator
            webView.setValue(false, forKey: "drawsBackground")
            webView.autoresizingMask = [.width, .height]
            self.dockCoordinator?.webView = webView
            containerView.webView = webView
            
            // Start settings sync timer
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.syncDockSettings()
            }
            
            // Start tracking mouse for hover
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                containerView.startMouseTracking()
            }
            
            // Add tracking area for mouse movement
            let trackingArea = NSTrackingArea(
                rect: containerView.bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: containerView,
                userInfo: nil
            )
            containerView.addTrackingArea(trackingArea)
            
            // Load radial dock HTML - minimalistic professional design
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="UTF-8">
            <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            html, body { width: 100%; height: 100%; background: transparent; overflow: hidden; }
            #notch { position: fixed; top: 0; left: 50%; transform: translateX(-50%); width: 150px; height: 8px; background: rgba(255,255,255,0.15); border-radius: 0 0 4px 4px; cursor: pointer; }
            #dock { position: fixed; top: 8px; left: 50%; transform: translateX(-50%); width: 380px; height: 200px; opacity: 0; pointer-events: none; transition: opacity 0.2s; }
            #dock.show, #dock.preview { opacity: 1; pointer-events: auto; }
            .icon { position: absolute; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: transform 0.12s, background 0.12s, opacity 0.12s; }
            .icon:hover { transform: translateY(var(--hover-lift, -6px)); }
            
            /* Dock Styles */
            .style-minimal .icon { background: transparent !important; border: none !important; box-shadow: none !important; }
            .style-bold .icon { border-width: 2px !important; font-weight: bold; }
            .style-glow .icon { box-shadow: 0 0 15px var(--glow-color, rgba(255,255,255,0.5)); }
            </style>
            </head>
            <body>
            <div id="notch"></div>
            <div id="dock"></div>
            <script>
            let dockButtons = [];
            const dock = document.getElementById('dock');
            
            let settings = {
                buttonShape: 'rounded',
                accentColor: '#FFFFFF',
                iconSize: 38,
                opacity: 0.12,
                contrast: 0.2,
                arcSpread: 70,
                dropDepth: 30,
                hoverLift: 6,
                borderWidth: 1,
                notchWidth: 150,
                dockStyle: 'normal'
            };
            
            function updateIconStyle(btn, shape, color, size, opacity, contrast, borderW) {
                btn.style.width = size + 'px';
                btn.style.height = size + 'px';
                btn.style.background = color + Math.round(opacity * 255).toString(16).padStart(2, '0');
                btn.style.border = borderW + 'px solid ' + color + Math.round(contrast * 255).toString(16).padStart(2, '0');
                btn.style.fontSize = (size * 0.47) + 'px';
                
                switch(shape) {
                    case 'square':
                        btn.style.borderRadius = '0px';
                        break;
                    case 'rounded':
                        btn.style.borderRadius = (size * 0.2) + 'px';
                        break;
                    case 'circle':
                        btn.style.borderRadius = '50%';
                        break;
                    case 'pill':
                        btn.style.borderRadius = (size * 0.5) + 'px';
                        break;
                }
            }
            
            function createDock() {
                const cx = 190, r = settings.arcSpread;
                dock.innerHTML = '';
                dock.className = '';
                
                // Apply dock style
                if (settings.dockStyle === 'minimal') {
                    dock.classList.add('style-minimal');
                } else if (settings.dockStyle === 'bold') {
                    dock.classList.add('style-bold');
                } else if (settings.dockStyle === 'glow') {
                    dock.classList.add('style-glow');
                    dock.style.setProperty('--glow-color', settings.accentColor + '80');
                }
                
                // Update notch
                const notch = document.getElementById('notch');
                notch.style.width = settings.notchWidth + 'px';
                
                const buttons = dockButtons.length > 0 ? dockButtons : [{icon: '⚙️', actionType: 'settings'}];
                
                buttons.forEach((button, i) => {
                    if (!button.isEnabled) return;
                    
                    const btn = document.createElement('button');
                    btn.className = 'icon';
                    btn.textContent = button.icon;
                    btn.dataset.actionType = button.actionType;
                    btn.dataset.actionValue = button.actionValue || '';
                    btn.dataset.title = button.title;
                    
                    // Evenly distribute icons from angle π (left) to 0 (right)
                    const angle = Math.PI * (1 - i / (buttons.length - 1 || 1));
                    btn.style.left = (cx + r * Math.cos(angle)) + 'px';
                    btn.style.top = (settings.dropDepth + r * Math.sin(angle) * 0.3) + 'px';
                    btn.style.transform = 'translate(-50%, -50%)';
                    btn.style.setProperty('--hover-lift', '-' + settings.hoverLift + 'px');
                    updateIconStyle(btn, settings.buttonShape, settings.accentColor, settings.iconSize, settings.opacity, settings.contrast, settings.borderWidth);
                    dock.appendChild(btn);
                });
            }
            
            window.updateButtons = function(buttons) {
                dockButtons = buttons;
                createDock();
            };
            
            createDock();
            
            document.addEventListener('click', function(e) {
                const btn = e.target.closest('.icon');
                if (btn) {
                    e.preventDefault();
                    const actionType = btn.dataset.actionType;
                    const actionValue = btn.dataset.actionValue;
                    window.webkit.messageHandlers.radialDock.postMessage({
                        type: 'buttonClick',
                        actionType: actionType,
                        actionValue: actionValue
                    });
                }
            });
            
            window.setExpanded = function(show) {
                dock.classList.toggle('show', show);
            };
            
            window.setPreviewMode = function(preview) {
                if (preview) {
                    dock.classList.add('preview');
                } else {
                    dock.classList.remove('preview');
                }
            };
            
            window.updateSettings = function(newSettings) {
                settings = {...settings, ...newSettings};
                createDock();
            };
            
            // Check every second if settings window is open
            setInterval(function() {
                window.webkit.messageHandlers.radialDock.postMessage({type: 'checkSettings'});
            }, 500);
            </script>
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: nil)
            
            containerView.addSubview(webView)
            window.contentView = containerView
            
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil as Any?)
            
            print(">>> Window created and ordered front")
            
            self.zenithWindow = window as? ZenithWindow
        }
        
        ShortcutManager.shared.startMonitoring { [weak self] type in
            if type == .pulse {
                DispatchQueue.main.async {
                    self?.zenithWindow?.pulse()
                }
            }
        }
    }
    
    private func setupStatusItem() {
        let menu = NSMenu()
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Zenith", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menu
        statusItem?.button?.image = createZIcon()
    }
    
    @objc func showSettingsWindow() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ShortcutManager.shared.stopMonitoring()
    }
}
