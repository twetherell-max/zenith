import SwiftUI
import WebKit

struct RadialDockView: NSViewRepresentable {
    @ObservedObject var state = ZenithState.shared
    
    private let htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8">
    <style>
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: transparent; }
    .container { position: relative; width: 100%; height: 100%; background: rgba(0,255,0,0.3); }
    .dock-root { position: absolute; left: 50%; top: 0; transform: translateX(-50%); width: 340px; height: 400px; opacity: 1; pointer-events: auto; }
    #notch { position: absolute; top: 0; left: 50%; transform: translateX(-50%); width: 200px; height: 80px; z-index: 100; cursor: pointer; background: rgba(255,0,0,0.5); }
    .dock-icon { position: absolute; width: 44px; height: 44px; border-radius: 12px; background: blue; border: 1px solid rgba(255,255,255,0.35); display: flex; align-items: center; justify-content: center; font-size: 22px; cursor: pointer; transition: transform 0.15s ease, background 0.15s ease; }
    .dock-icon:hover { transform: translateY(-8px) scale(1.12); background: rgba(255,255,255,0.35); }
    </style>
    </head>
    <body style="background:purple;margin:0;padding:0;">
    <div style="position:absolute;top:20px;left:50%;transform:translateX(-50%);font-size:40px;color:white;z-index:999;">TEST HTML</div>
    <div class="container" id="container">
      <div id="notch"></div>
      <div class="dock-root" id="dockRoot">
        <div id="dock-icons"></div>
      </div>
    </div>
    <script>
    const ICONS = ["🧭", "📁", "⚙️", "🎵", "📄"];
    const CENTER_X = 170, CENTER_Y = 100, RADIUS = 100;
    
    function updateIcons(data) {
      if (!data || !data.length) return;
      const layer = document.getElementById("dock-icons");
      layer.innerHTML = "";
      data.forEach((item, i) => {
        const t = (i + 0.5) / data.length;
        const angle = Math.PI - t * Math.PI;
        const x = CENTER_X + RADIUS * Math.cos(angle);
        const y = CENTER_Y + RADIUS * Math.sin(angle);
        const btn = document.createElement("button");
        btn.className = "dock-icon";
        btn.textContent = item.icon || "❓";
        btn.style.left = x + "px";
        btn.style.top = y + "px";
        btn.style.transform = "translate(-50%, -50%)";
        btn.onclick = () => {
          if (window.webkit && window.webkit.messageHandlers.radialDock) {
            window.webkit.messageHandlers.radialDock.postMessage({type: "iconClick", id: item.id, action: item.action});
          }
        };
        layer.appendChild(btn);
      });
    }
    
    window.setExpanded = function(visible) {
      const dock = document.getElementById("dockRoot");
      if (visible) {
        dock.classList.add("visible");
      } else {
        dock.classList.remove("visible");
      }
    };
    
    // Initialize with default icons
    updateIcons(ICONS.map((icon,i) => ({icon:icon, id:i})));
    </script>
    </body>
    </html>
    """
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "radialDock")
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 1000), configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let segments = ZenithState.shared.visibleSegments
        let iconData = segments.map { segment -> [String: Any] in
            return [
                "id": segment.id.uuidString,
                "icon": sfSymbolToEmoji(segment.icon, fallback: String(segment.title.prefix(1))),
                "action": segment.action ?? ""
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: iconData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webView.evaluateJavaScript("updateIcons(\(jsonString))") { _, _ in }
        }
        
        let expandedJS = ZenithState.shared.isExpanded ? "true" : "false"
        webView.evaluateJavaScript("setExpanded(\(expandedJS))") { _, _ in }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "radialDock",
                  let body = message.body as? [String: Any],
                  let type = body["type"] as? String else { return }
            
            if type == "iconClick", let idString = body["id"] as? String, let uuid = UUID(uuidString: idString) {
                if let segment = ZenithState.shared.findSegment(by: uuid) {
                    ZenithState.shared.executeAction(for: segment)
                }
            }
        }
    }
    
    private func sfSymbolToEmoji(_ symbol: String, fallback: String) -> String {
        let mapping: [String: String] = ["globe": "🌐", "safari": "🧭", "music.note": "🎵", "folder.fill": "📁", "gearshape.fill": "⚙️", "playpause.fill": "▶️", "forward.fill": "⏭️", "backward.fill": "⏮️", "arrow.down.circle": "⬇️", "doc.fill": "📄", "desktopcomputer": "🖥️", "person": "👤", "chevron.left.forwardslash.chevron.right": "💻", "app.badge": "📱"]
        return mapping[symbol] ?? fallback
    }
}
