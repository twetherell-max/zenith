import AppKit
import Combine
import Foundation

struct MusicTrackInfo {
    let title: String
    let artist: String
    let album: String
    let artwork: NSImage?
    let isPlaying: Bool
    let service: DockButton.MusicService
}

class MusicController: ObservableObject {
    static let shared = MusicController()
    
    @Published var currentTrack: MusicTrackInfo?
    @Published var isPlaying: Bool = false
    
    private var refreshTimer: Timer?
    private var isInitialized = false
    
    private init() {}
    
    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        
        DispatchQueue.main.async { [weak self] in
            self?.refreshCurrentTrack()
            self?.startAutoRefresh()
        }
    }
    
    func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshCurrentTrack()
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refreshCurrentTrack() {
        if let track = getAppleMusicTrack() {
            currentTrack = track
            isPlaying = track.isPlaying
            return
        }
        
        if let track = getSpotifyTrack() {
            currentTrack = track
            isPlaying = track.isPlaying
            return
        }
        
        currentTrack = nil
        isPlaying = false
    }
    
    private func getAppleMusicTrack() -> MusicTrackInfo? {
        let script = """
        tell application "System Events"
            if (exists (process "Music")) then
                tell application "Music"
                    if player state is playing or player state is paused then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set albumName to album of current track
                        set playingState to player state
                        
                        try
                            set artworkData to raw data of artwork 1 of current track
                            return trackName & "|||" & artistName & "|||" & albumName & "|||" & playingState & "|||HAS_ARTWORK"
                        on error
                            return trackName & "|||" & artistName & "|||" & albumName & "|||" & playingState & "|||NO_ARTWORK"
                        end try
                    end if
                end tell
            end if
        end tell
        return "NO_TRACK"
        """
        
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        let result = appleScript.executeAndReturnError(&error)
        
        guard let resultString = result.stringValue, resultString != "NO_TRACK" else { return nil }
        
        let components = resultString.components(separatedBy: "|||")
        guard components.count >= 5 else { return nil }
        
        let title = components[0]
        let artist = components[1]
        let album = components[2]
        let state = components[3]
        let hasArtwork = components[4] == "HAS_ARTWORK"
        let isPlaying = state == "playing"
        
        var artwork: NSImage? = nil
        if hasArtwork {
            artwork = getAppleMusicArtwork()
        }
        
        return MusicTrackInfo(
            title: title,
            artist: artist,
            album: album,
            artwork: artwork,
            isPlaying: isPlaying,
            service: .appleMusic
        )
    }
    
    private func getAppleMusicArtwork() -> NSImage? {
        let script = """
        tell application "Music"
            try
                return raw data of artwork 1 of current track
            end try
        end tell
        return missing value
        """
        
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        let result = appleScript.executeAndReturnError(&error)
        
        return NSImage(data: result.data)
    }
    
    private func getSpotifyTrack() -> MusicTrackInfo? {
        let script = """
        tell application "System Events"
            if (exists (process "Spotify")) then
                tell application "Spotify"
                    if player state is playing or player state is paused then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set albumName to album of current track
                        set playingState to player state
                        set artworkUrl to artwork url of current track
                        return trackName & "|||" & artistName & "|||" & albumName & "|||" & playingState & "|||" & artworkUrl
                    end if
                end tell
            end if
        end tell
        return "NO_TRACK"
        """
        
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        let result = appleScript.executeAndReturnError(&error)
        
        guard let resultString = result.stringValue, resultString != "NO_TRACK" else { return nil }
        
        let components = resultString.components(separatedBy: "|||")
        guard components.count >= 5 else { return nil }
        
        let title = components[0]
        let artist = components[1]
        let album = components[2]
        let state = components[3]
        let artworkUrl = components[4]
        let isPlaying = state == "playing"
        
        var artwork: NSImage? = nil
        if !artworkUrl.isEmpty && artworkUrl != "missing value" {
            artwork = fetchSpotifyArtwork(from: artworkUrl)
        }
        
        return MusicTrackInfo(
            title: title,
            artist: artist,
            album: album,
            artwork: artwork,
            isPlaying: isPlaying,
            service: .spotify
        )
    }
    
    private func fetchSpotifyArtwork(from urlString: String) -> NSImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let semaphore = DispatchSemaphore(value: 0)
        var resultImage: NSImage? = nil
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = NSImage(data: data) {
                resultImage = image
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 2.0)
        
        return resultImage
    }
}
