import AppKit
import SwiftUI

class AIQueryWindow: NSWindow {
    static let shared = AIQueryWindow()
    
    private var hostingView: NSHostingView<AIQueryView>!
    
    private init() {
        let contentView = AIQueryView()
        let hostingView = NSHostingView(rootView: contentView)
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.hostingView = hostingView
        self.contentView = hostingView
        
        setupWindow()
    }
    
    private func setupWindow() {
        title = "Quick Query"
        isReleasedWhenClosed = false
        backgroundColor = NSColor.windowBackgroundColor
        isOpaque = false
        hasShadow = true
        level = .floating
        
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    func show(at position: CGPoint) {
        setFrameOrigin(position)
        
        if !isVisible {
            orderFront(nil)
        }
        
        alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        }
    }
    
    func hideWindow() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            self.animator().alphaValue = 0.0
        } completionHandler: {
            self.orderOut(nil)
        }
    }
}

struct AIQueryView: View {
    @StateObject private var aiHelper = AIHelper.shared
    @State private var queryText = ""
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            if !aiHelper.isConfigured {
                setupPromptView
            } else {
                queryView
            }
        }
        .frame(width: 400, height: 200)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingSettings) {
            AIConfigView()
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.orange)
            
            Text("Quick Query")
                .font(.headline)
            
            Spacer()
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "gear")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("AI Settings")
            
            Button(action: {
                AIQueryWindow.shared.hideWindow()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Close")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var setupPromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("API Key Required")
                .font(.headline)
            
            Text("Add your OpenAI API key in settings to enable Quick Query.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Open Settings") {
                showingSettings = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var queryView: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Ask anything...", text: $queryText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        submitQuery()
                    }
                
                Button(action: submitQuery) {
                    if aiHelper.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(queryText.isEmpty || aiHelper.isLoading)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            if !aiHelper.currentResponse.isEmpty || aiHelper.lastError != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if let error = aiHelper.lastError {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .font(.caption)
                        } else {
                            Text(aiHelper.currentResponse)
                                .font(.body)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 100)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
    
    private func submitQuery() {
        guard !queryText.isEmpty else { return }
        let query = queryText
        queryText = ""
        
        aiHelper.query(query) { response in
            if response.isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if !AIQueryWindow.shared.isVisible {
                        aiHelper.clearResponse()
                    }
                }
            }
        }
    }
}

struct AIConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = AIHelper.shared.apiKey ?? ""
    @State private var personality: AIPersonality = AIHelper.shared.personality
    @State private var showingSaveSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                apiKeySection
                personalitySection
                infoSection
            }
            .padding()
            
            Spacer()
            
            footerView
        }
        .frame(width: 400, height: 320)
        .alert("Settings Saved", isPresented: $showingSaveSuccess) {
            Button("OK") { dismiss() }
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("AI Settings")
                    .font(.headline)
                Text("Configure Quick Query")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OpenAI API Key")
                .font(.subheadline)
                .fontWeight(.medium)
            
            SecureField("sk-...", text: $apiKey)
                .textFieldStyle(.roundedBorder)
            
            Text("Get your API key from platform.openai.com")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personality")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("", selection: $personality) {
                ForEach(AIPersonality.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            Text(personalityHint)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var personalityHint: String {
        switch personality {
        case .friendly:
            return "Warm, conversational responses with light humor"
        case .efficient:
            return "Direct, no-filler answers prioritizing clarity"
        }
    }
    
    private var infoSection: some View {
        Group {
            Text("Quick Query is a single-shot AI assistant accessible from the dock bar. Ask questions without context switching.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
        }
    }
    
    private var footerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            
            Spacer()
            
            Button("Save") {
                saveSettings()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func saveSettings() {
        AIHelper.shared.setApiKey(apiKey)
        AIHelper.shared.personality = personality
        showingSaveSuccess = true
    }
}
