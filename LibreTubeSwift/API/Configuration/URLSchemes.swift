import Foundation
import UIKit

/// URL Schemes and Deep Linking handler converted from AndroidManifest.xml
public class URLSchemes {
    
    // MARK: - URL Scheme Types
    public enum URLSchemeType {
        case youtube
        case piped
        case share
        case custom(String)
        
        public var scheme: String {
            switch self {
            case .youtube, .piped, .share:
                return "https"
            case .custom(let scheme):
                return scheme
            }
        }
    }
    
    // MARK: - URL Content Types
    public enum URLContentType {
        case video
        case channel
        case playlist
        case search
        case unknown
        
        public static func detect(from url: URL) -> URLContentType {
            let path = url.path
            
            if AppConfiguration.videoPathPrefixes.contains(where: { path.hasPrefix($0) }) {
                return .video
            } else if AppConfiguration.channelPathPrefixes.contains(where: { path.hasPrefix($0) }) {
                return .channel
            } else if AppConfiguration.playlistPathPrefixes.contains(where: { path.hasPrefix($0) }) {
                return .playlist
            } else if AppConfiguration.searchPathPrefixes.contains(where: { path.hasPrefix($0) }) {
                return .search
            }
            
            return .unknown
        }
    }
    
    // MARK: - URL Handler
    public static func handleURL(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        
        // Check if it's a YouTube URL
        if AppConfiguration.isValidYouTubeURL(url) {
            return handleYouTubeURL(url)
        }
        
        // Check if it's a Piped URL
        if AppConfiguration.isValidPipedURL(url) {
            return handlePipedURL(url)
        }
        
        // Check if it's a share URL
        if url.scheme == "http" || url.scheme == "https" {
            return handleShareURL(url)
        }
        
        return false
    }
    
    // MARK: - YouTube URL Handling
    private static func handleYouTubeURL(_ url: URL) -> Bool {
        let contentType = URLContentType.detect(from: url)
        
        switch contentType {
        case .video:
            return handleVideoURL(url, platform: .youtube)
        case .channel:
            return handleChannelURL(url, platform: .youtube)
        case .playlist:
            return handlePlaylistURL(url, platform: .youtube)
        case .search:
            return handleSearchURL(url, platform: .youtube)
        case .unknown:
            return false
        }
    }
    
    // MARK: - Piped URL Handling
    private static func handlePipedURL(_ url: URL) -> Bool {
        let contentType = URLContentType.detect(from: url)
        
        switch contentType {
        case .video:
            return handleVideoURL(url, platform: .piped)
        case .channel:
            return handleChannelURL(url, platform: .piped)
        case .playlist:
            return handlePlaylistURL(url, platform: .piped)
        case .search:
            return handleSearchURL(url, platform: .piped)
        case .unknown:
            return false
        }
    }
    
    // MARK: - Share URL Handling
    private static func handleShareURL(_ url: URL) -> Bool {
        // Handle text sharing
        if url.absoluteString.hasPrefix("text://") {
            let text = String(url.absoluteString.dropFirst(7))
            return handleSharedText(text)
        }
        
        // Handle URL sharing
        return handleSharedURL(url)
    }
    
    // MARK: - Content Type Handlers
    private static func handleVideoURL(_ url: URL, platform: URLSchemeType) -> Bool {
        // Extract video ID from URL
        guard let videoId = extractVideoId(from: url) else { return false }
        
        // Create user activity for video
        let activity = NSUserActivity(activityType: "com.github.libretube.watch-video")
        activity.webpageURL = url
        activity.userInfo = [
            "videoId": videoId,
            "platform": platform.scheme,
            "contentType": "video"
        ]
        
        // Post notification for video handling
        NotificationCenter.default.post(
            name: .videoURLReceived,
            object: nil,
            userInfo: [
                "url": url,
                "videoId": videoId,
                "platform": platform.scheme
            ]
        )
        
        return true
    }
    
    private static func handleChannelURL(_ url: URL, platform: URLSchemeType) -> Bool {
        // Extract channel ID from URL
        guard let channelId = extractChannelId(from: url) else { return false }
        
        // Create user activity for channel
        let activity = NSUserActivity(activityType: "com.github.libretube.open-channel")
        activity.webpageURL = url
        activity.userInfo = [
            "channelId": channelId,
            "platform": platform.scheme,
            "contentType": "channel"
        ]
        
        // Post notification for channel handling
        NotificationCenter.default.post(
            name: .channelURLReceived,
            object: nil,
            userInfo: [
                "url": url,
                "channelId": channelId,
                "platform": platform.scheme
            ]
        )
        
        return true
    }
    
    private static func handlePlaylistURL(_ url: URL, platform: URLSchemeType) -> Bool {
        // Extract playlist ID from URL
        guard let playlistId = extractPlaylistId(from: url) else { return false }
        
        // Create user activity for playlist
        let activity = NSUserActivity(activityType: "com.github.libretube.open-playlist")
        activity.webpageURL = url
        activity.userInfo = [
            "playlistId": playlistId,
            "platform": platform.scheme,
            "contentType": "playlist"
        ]
        
        // Post notification for playlist handling
        NotificationCenter.default.post(
            name: .playlistURLReceived,
            object: nil,
            userInfo: [
                "url": url,
                "playlistId": playlistId,
                "platform": platform.scheme
            ]
        )
        
        return true
    }
    
    private static func handleSearchURL(_ url: URL, platform: URLSchemeType) -> Bool {
        // Extract search query from URL
        guard let searchQuery = extractSearchQuery(from: url) else { return false }
        
        // Create user activity for search
        let activity = NSUserActivity(activityType: "com.github.libretube.search")
        activity.webpageURL = url
        activity.userInfo = [
            "searchQuery": searchQuery,
            "platform": platform.scheme,
            "contentType": "search"
        ]
        
        // Post notification for search handling
        NotificationCenter.default.post(
            name: .searchURLReceived,
            object: nil,
            userInfo: [
                "url": url,
                "searchQuery": searchQuery,
                "platform": platform.scheme
            ]
        )
        
        return true
    }
    
    private static func handleSharedText(_ text: String) -> Bool {
        // Post notification for shared text
        NotificationCenter.default.post(
            name: .sharedTextReceived,
            object: nil,
            userInfo: ["text": text]
        )
        
        return true
    }
    
    private static func handleSharedURL(_ url: URL) -> Bool {
        // Post notification for shared URL
        NotificationCenter.default.post(
            name: .sharedURLReceived,
            object: nil,
            userInfo: ["url": url]
        )
        
        return true
    }
    
    // MARK: - URL Parsing Helpers
    private static func extractVideoId(from url: URL) -> String? {
        let path = url.path
        
        // Handle different video URL patterns
        if path.hasPrefix("/v/") {
            return String(path.dropFirst(3))
        } else if path.hasPrefix("/embed/") {
            return String(path.dropFirst(7))
        } else if path.hasPrefix("/watch") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "v" })?
                .value
        } else if path.hasPrefix("/shorts/") {
            return String(path.dropFirst(8))
        } else if path.hasPrefix("/live/") {
            return String(path.dropFirst(6))
        }
        
        return nil
    }
    
    private static func extractChannelId(from url: URL) -> String? {
        let path = url.path
        
        if path.hasPrefix("/channel/") {
            return String(path.dropFirst(9))
        } else if path.hasPrefix("/user/") {
            return String(path.dropFirst(6))
        } else if path.hasPrefix("/c/") {
            return String(path.dropFirst(3))
        }
        
        return nil
    }
    
    private static func extractPlaylistId(from url: URL) -> String? {
        let path = url.path
        
        if path.hasPrefix("/playlist") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "list" })?
                .value
        } else if path.hasPrefix("/watch_videos") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "list" })?
                .value
        }
        
        return nil
    }
    
    private static func extractSearchQuery(from url: URL) -> String? {
        let path = url.path
        
        if path.hasPrefix("/results") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "search_query" })?
                .value
        }
        
        return nil
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let videoURLReceived = Notification.Name("videoURLReceived")
    static let channelURLReceived = Notification.Name("channelURLReceived")
    static let playlistURLReceived = Notification.Name("playlistURLReceived")
    static let searchURLReceived = Notification.Name("searchURLReceived")
    static let sharedTextReceived = Notification.Name("sharedTextReceived")
    static let sharedURLReceived = Notification.Name("sharedURLReceived")
}