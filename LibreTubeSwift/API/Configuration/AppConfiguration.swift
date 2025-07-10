import Foundation
import UIKit

/// App Configuration converted from AndroidManifest.xml
public struct AppConfiguration {
    
    // MARK: - App Info
    public static let appName = "LibreTube"
    public static let bundleIdentifier = "com.github.libretube"
    public static let version = "1.0.0"
    public static let buildNumber = "1"
    
    // MARK: - Supported URL Schemes
    public static let supportedURLSchemes = [
        "http",
        "https"
    ]
    
    // MARK: - Supported Domains
    public static let supportedYouTubeDomains = [
        "youtube.com",
        "m.youtube.com", 
        "www.youtube.com",
        "music.youtube.com",
        "youtu.be"
    ]
    
    public static let supportedPipedDomains = [
        "piped.adminforge.de",
        "piped.astartes.nl",
        "piped.coldforge.xyz",
        "piped.drgns.space",
        "piped.ducks.party",
        "piped.lunar.icu",
        "piped.ngn.tf",
        "piped.projectsegfau.lt",
        "piped.r4fo.com",
        "piped.smnz.de",
        "piped.syncpundit.io",
        "piped.us.projectsegfau.lt",
        "piped.video"
    ]
    
    // MARK: - URL Path Prefixes
    public static let videoPathPrefixes = [
        "/v/",
        "/embed/",
        "/watch",
        "/shorts/",
        "/live/"
    ]
    
    public static let channelPathPrefixes = [
        "/channel/",
        "/user/",
        "/c/"
    ]
    
    public static let playlistPathPrefixes = [
        "/playlist",
        "/watch_videos"
    ]
    
    public static let searchPathPrefixes = [
        "/results"
    ]
    
    // MARK: - App Icons
    public enum AppIcon: String, CaseIterable {
        case `default` = "ic_launcher"
        case gradient = "ic_gradient"
        case light = "ic_launcher_light"
        case fire = "ic_fire"
        case flame = "ic_flame"
        case shaped = "ic_shaped"
        case torch = "ic_torch"
        case legacy = "ic_legacy"
        case bird = "ic_bird"
        
        public var displayName: String {
            switch self {
            case .default: return "Default"
            case .gradient: return "Gradient"
            case .light: return "Light"
            case .fire: return "Fire"
            case .flame: return "Flame"
            case .shaped: return "Shaped"
            case .torch: return "Torch"
            case .legacy: return "Legacy"
            case .bird: return "Bird"
            }
        }
        
        public var iconName: String {
            return rawValue
        }
    }
    
    // MARK: - Features
    public static let supportsPictureInPicture = true
    public static let supportsBackgroundAudio = true
    public static let supportsLeanback = true
    public static let supportsTouchscreen = true
    
    // MARK: - Network Security
    public static let allowsArbitraryLoads = false
    public static let allowsLocalNetworking = true
    
    // MARK: - Background Modes
    public static let backgroundModes: [String] = [
        "audio",
        "background-processing",
        "background-fetch"
    ]
    
    // MARK: - Capabilities
    public static let capabilities: [String] = [
        "com.apple.developer.associated-domains",
        "com.apple.developer.background-modes",
        "com.apple.developer.networking.multipath",
        "com.apple.developer.networking.wifi-info"
    ]
    
    // MARK: - App Groups
    public static let appGroupIdentifier = "group.com.github.libretube"
    
    // MARK: - User Activity Types
    public static let userActivityTypes = [
        "com.github.libretube.watch-video",
        "com.github.libretube.open-channel",
        "com.github.libretube.open-playlist",
        "com.github.libretube.search"
    ]
    
    // MARK: - Notification Categories
    public static let notificationCategories = [
        "com.github.libretube.download",
        "com.github.libretube.playback",
        "com.github.libretube.playlist"
    ]
    
    // MARK: - Shared Container
    public static let sharedContainerURL: URL? = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }()
    
    // MARK: - Cache Directory
    public static let cacheDirectory: URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }()
    
    // MARK: - Documents Directory
    public static let documentsDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    // MARK: - Download Directory
    public static let downloadDirectory: URL = {
        return documentsDirectory.appendingPathComponent("Downloads")
    }()
    
    // MARK: - Database Directory
    public static let databaseDirectory: URL = {
        return documentsDirectory.appendingPathComponent("Database")
    }()
    
    // MARK: - Settings
    public struct Settings {
        public static let defaultInstance = "https://piped.projectsegfau.lt"
        public static let maxCacheSize: Int64 = 1024 * 1024 * 1024 // 1GB
        public static let maxDownloadConcurrency = 3
        public static let maxPlaylistItems = 1000
        public static let autoPlayNext = true
        public static let backgroundPlayback = true
        public static let pictureInPicture = true
    }
    
    // MARK: - Validation
    public static func isValidYouTubeURL(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        return supportedYouTubeDomains.contains(host)
    }
    
    public static func isValidPipedURL(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        return supportedPipedDomains.contains(host)
    }
    
    public static func isVideoURL(_ url: URL) -> Bool {
        let path = url.path
        return videoPathPrefixes.contains { path.hasPrefix($0) }
    }
    
    public static func isChannelURL(_ url: URL) -> Bool {
        let path = url.path
        return channelPathPrefixes.contains { path.hasPrefix($0) }
    }
    
    public static func isPlaylistURL(_ url: URL) -> Bool {
        let path = url.path
        return playlistPathPrefixes.contains { path.hasPrefix($0) }
    }
    
    public static func isSearchURL(_ url: URL) -> Bool {
        let path = url.path
        return searchPathPrefixes.contains { path.hasPrefix($0) }
    }
}