import Foundation

/// Model đại diện cho một video item trong danh sách
public struct StreamItem: Codable, Identifiable, Hashable {
    
    // MARK: - Properties
    public let id: String
    public let url: String?
    public let type: String?
    public var title: String?
    public var thumbnail: String?
    public let uploaderName: String?
    public let uploaderUrl: String?
    public let uploaderAvatar: String?
    public let uploadedDate: String?
    public let duration: Int64?
    public let views: Int64?
    public let uploaderVerified: Bool?
    public let uploaded: Int64
    public let shortDescription: String?
    public let isShort: Bool
    
    // MARK: - Computed Properties
    public var isLive: Bool {
        return !isShort && (duration == nil || duration! <= 0)
    }
    
    public var isUpcoming: Bool {
        return uploaded > Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    // MARK: - Initialization
    public init(
        id: String,
        url: String? = nil,
        type: String? = nil,
        title: String? = nil,
        thumbnail: String? = nil,
        uploaderName: String? = nil,
        uploaderUrl: String? = nil,
        uploaderAvatar: String? = nil,
        uploadedDate: String? = nil,
        duration: Int64? = nil,
        views: Int64? = nil,
        uploaderVerified: Bool? = nil,
        uploaded: Int64 = 0,
        shortDescription: String? = nil,
        isShort: Bool = false
    ) {
        self.id = id
        self.url = url
        self.type = type
        self.title = title
        self.thumbnail = thumbnail
        self.uploaderName = uploaderName
        self.uploaderUrl = uploaderUrl
        self.uploaderAvatar = uploaderAvatar
        self.uploadedDate = uploadedDate
        self.duration = duration
        self.views = views
        self.uploaderVerified = uploaderVerified
        self.uploaded = uploaded
        self.shortDescription = shortDescription
        self.isShort = isShort
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case url, type, title, thumbnail, uploaderName, uploaderUrl, uploaderAvatar
        case uploadedDate, duration, views, uploaderVerified, uploaded, shortDescription, isShort
    }
    
    // MARK: - Custom Decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Extract video ID from URL if available
        if let url = try container.decodeIfPresent(String.self, forKey: .url) {
            self.id = Self.extractVideoID(from: url)
        } else {
            self.id = UUID().uuidString
        }
        
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.uploaderName = try container.decodeIfPresent(String.self, forKey: .uploaderName)
        self.uploaderUrl = try container.decodeIfPresent(String.self, forKey: .uploaderUrl)
        self.uploaderAvatar = try container.decodeIfPresent(String.self, forKey: .uploaderAvatar)
        self.uploadedDate = try container.decodeIfPresent(String.self, forKey: .uploadedDate)
        self.duration = try container.decodeIfPresent(Int64.self, forKey: .duration)
        self.views = try container.decodeIfPresent(Int64.self, forKey: .views)
        self.uploaderVerified = try container.decodeIfPresent(Bool.self, forKey: .uploaderVerified)
        self.uploaded = try container.decodeIfPresent(Int64.self, forKey: .uploaded) ?? 0
        self.shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.isShort = try container.decodeIfPresent(Bool.self, forKey: .isShort) ?? false
    }
    
    // MARK: - Helper Methods
    private static func extractVideoID(from url: String) -> String {
        // Extract YouTube video ID from URL
        // Example: https://www.youtube.com/watch?v=dQw4w9WgXcQ -> dQw4w9WgXcQ
        if let range = url.range(of: "v=") {
            let videoID = String(url[range.upperBound...])
            if let ampersandRange = videoID.range(of: "&") {
                return String(videoID[..<ampersandRange.lowerBound])
            }
            return videoID
        }
        return url
    }
    
    // MARK: - Constants
    public static let typeStream = "stream"
    public static let typeChannel = "channel"
    public static let typePlaylist = "playlist"
}

// MARK: - Extensions
extension StreamItem {
    
    /// Convert to local playlist item
    public func toLocalPlaylistItem(playlistId: String) -> LocalPlaylistItem {
        return LocalPlaylistItem(
            playlistId: playlistId,
            videoId: id,
            title: title,
            thumbnailUrl: thumbnail,
            uploader: uploaderName,
            uploaderUrl: uploaderUrl,
            uploaderAvatar: uploaderAvatar,
            uploadDate: uploadedDate,
            duration: duration
        )
    }
    
    /// Convert to feed item
    public func toFeedItem() -> SubscriptionsFeedItem {
        return SubscriptionsFeedItem(
            videoId: id,
            title: title,
            thumbnail: thumbnail,
            uploaderName: uploaderName,
            uploaded: uploaded,
            uploaderAvatar: uploaderAvatar,
            uploaderUrl: uploaderUrl,
            duration: duration,
            uploaderVerified: uploaderVerified ?? false,
            shortDescription: shortDescription,
            views: views,
            isShort: isShort
        )
    }
    
    /// Convert to watch history item
    public func toWatchHistoryItem(videoId: String) -> WatchHistoryItem {
        return WatchHistoryItem(
            videoId: videoId,
            title: title,
            uploadDate: Date(timeIntervalSince1970: TimeInterval(uploaded / 1000)),
            uploader: uploaderName,
            uploaderUrl: uploaderUrl,
            uploaderAvatar: uploaderAvatar,
            thumbnailUrl: thumbnail,
            duration: duration
        )
    }
}

// MARK: - Supporting Models (Placeholder)
public struct LocalPlaylistItem {
    let playlistId: String
    let videoId: String
    let title: String?
    let thumbnailUrl: String?
    let uploader: String?
    let uploaderUrl: String?
    let uploaderAvatar: String?
    let uploadDate: String?
    let duration: Int64?
}

public struct SubscriptionsFeedItem {
    let videoId: String
    let title: String?
    let thumbnail: String?
    let uploaderName: String?
    let uploaded: Int64
    let uploaderAvatar: String?
    let uploaderUrl: String?
    let duration: Int64?
    let uploaderVerified: Bool
    let shortDescription: String?
    let views: Int64?
    let isShort: Bool
}

public struct WatchHistoryItem {
    let videoId: String
    let title: String?
    let uploadDate: Date
    let uploader: String?
    let uploaderUrl: String?
    let uploaderAvatar: String?
    let thumbnailUrl: String?
    let duration: Int64?
}