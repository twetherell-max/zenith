import AppKit
import Combine

class MusicPopupWindow: NSPanel {
    private var cancellables = Set<AnyCancellable>()
    private var autoCloseTimer: Timer?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 120),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupUI()
        positionWindow()
        observeMusic()
    }
    
    private func setupWindow() {
        self.title = "Now Playing"
        self.isFloatingPanel = true
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isReleasedWhenClosed = false
    }
    
    private func setupUI() {
        let contentView = NSView(frame: self.contentView!.bounds)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        contentView.layer?.cornerRadius = 12
        
        self.contentView = contentView
    }
    
    private func positionWindow() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowSize = self.frame.size
        
        let x = screenFrame.midX - windowSize.width / 2
        let y = screenFrame.midY - windowSize.height / 2 + 150
        
        self.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    private func observeMusic() {
        MusicController.shared.$currentTrack
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                self?.updateContent(with: track)
            }
            .store(in: &cancellables)
    }
    
    private func updateContent(with track: MusicTrackInfo?) {
        guard let contentView = self.contentView else { return }
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let track = track else {
            let noMusicLabel = NSTextField(labelWithString: "No music playing")
            noMusicLabel.font = NSFont.systemFont(ofSize: 14)
            noMusicLabel.textColor = .secondaryLabelColor
            noMusicLabel.alignment = .center
            noMusicLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(noMusicLabel)
            
            NSLayoutConstraint.activate([
                noMusicLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                noMusicLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            return
        }
        
        let artworkSize: CGFloat = 80
        let padding: CGFloat = 16
        
        let artworkView = NSImageView()
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.image = track.artwork ?? NSImage(systemSymbolName: "music.note", accessibilityDescription: "Music")
        artworkView.imageScaling = .scaleProportionallyUpOrDown
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
        artworkView.layer?.masksToBounds = true
        contentView.addSubview(artworkView)
        
        let infoStack = NSStackView()
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.orientation = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4
        contentView.addSubview(infoStack)
        
        let titleLabel = NSTextField(labelWithString: track.title)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.maximumNumberOfLines = 1
        
        let artistLabel = NSTextField(labelWithString: track.artist)
        artistLabel.font = NSFont.systemFont(ofSize: 12)
        artistLabel.textColor = .secondaryLabelColor
        artistLabel.lineBreakMode = .byTruncatingTail
        artistLabel.maximumNumberOfLines = 1
        
        let albumLabel = NSTextField(labelWithString: track.album)
        albumLabel.font = NSFont.systemFont(ofSize: 11)
        albumLabel.textColor = .tertiaryLabelColor
        albumLabel.lineBreakMode = .byTruncatingTail
        albumLabel.maximumNumberOfLines = 1
        
        let serviceLabel = NSTextField(labelWithString: track.service == .appleMusic ? "Apple Music" : "Spotify")
        serviceLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        serviceLabel.textColor = track.service == .appleMusic ? NSColor(hex: "#FA243C") ?? .red : NSColor(hex: "#1DB954") ?? .green
        
        infoStack.addArrangedSubview(titleLabel)
        infoStack.addArrangedSubview(artistLabel)
        infoStack.addArrangedSubview(albumLabel)
        infoStack.addArrangedSubview(serviceLabel)
        
        NSLayoutConstraint.activate([
            artworkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            artworkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artworkView.widthAnchor.constraint(equalToConstant: artworkSize),
            artworkView.heightAnchor.constraint(equalToConstant: artworkSize),
            
            infoStack.leadingAnchor.constraint(equalTo: artworkView.trailingAnchor, constant: 12),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            infoStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        resetAutoCloseTimer()
    }
    
    private func resetAutoCloseTimer() {
        autoCloseTimer?.invalidate()
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.close()
        }
    }
    
    func show() {
        MusicController.shared.refreshCurrentTrack()
        positionWindow()
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override func close() -> Void {
        autoCloseTimer?.invalidate()
        cancellables.removeAll()
        super.close()
    }
    
    override func mouseEntered(with event: NSEvent) {
        autoCloseTimer?.invalidate()
    }
    
    override func mouseExited(with event: NSEvent) {
        resetAutoCloseTimer()
    }
}
