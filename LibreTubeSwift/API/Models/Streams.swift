import Foundation

/// Model đại diện cho thông tin chi tiết của một video stream
public struct Streams: Codable, Identifiable {
    
    // MARK: - Properties
    public let id: String
    public var title: String
    public let description: String
    public let uploadTimestamp: Date?
    public let uploaded: Int64?
    public let uploader: String
    public let uploaderUrl: String
    public let uploaderAvatar: String?
    public var thumbnailUrl: String
    public let category: String
    public let license: String
    public let visibility: String
    public let tags: [String]
    public let metaInfo: [MetaInfo]
    public let hls: String?
    public let dash: String?
    public let lbryId: String?
    public let uploaderVerified: Bool
    public let duration: Int64
    public let views: Int64
    public let likes: Int64
    public let dislikes: Int64
    public let audioStreams: [PipedStream]
    public let videoStreams: [PipedStream]
    public var relatedStreams: [StreamItem]
    public let subtitles: [Subtitle]
    public let livestream: Bool
    public let proxyUrl: String?
    public let chapters: [ChapterSegment]
    public let uploaderSubscriberCount: Int64
    public let previewFrames: [PreviewFrames]
    
    // MARK: - Computed Properties
    public var isLive: Bool {
        return livestream || duration <= 0
    }
    
    // MARK: - Initialization
    public init(
        id: String,
        title: String,
        description: String,
        uploadTimestamp: Date? = nil,
        uploaded: Int64? = nil,
        uploader: String,
        uploaderUrl: String,
        uploaderAvatar: String? = nil,
        thumbnailUrl: String,
        category: String,
        license: String = "YouTube licence",
        visibility: String = "public",
        tags: [String] = [],
        metaInfo: [MetaInfo] = [],
        hls: String? = nil,
        dash: String? = nil,
        lbryId: String? = nil,
        uploaderVerified: Bool,
        duration: Int64,
        views: Int64 = 0,
        likes: Int64 = 0,
        dislikes: Int64 = 0,
        audioStreams: [PipedStream] = [],
        videoStreams: [PipedStream] = [],
        relatedStreams: [StreamItem] = [],
        subtitles: [Subtitle] = [],
        livestream: Bool = false,
        proxyUrl: String? = nil,
        chapters: [ChapterSegment] = [],
        uploaderSubscriberCount: Int64 = 0,
        previewFrames: [PreviewFrames] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.uploadTimestamp = uploadTimestamp
        self.uploaded = uploaded
        self.uploader = uploader
        self.uploaderUrl = uploaderUrl
        self.uploaderAvatar = uploaderAvatar
        self.thumbnailUrl = thumbnailUrl
        self.category = category
        self.license = license
        self.visibility = visibility
        self.tags = tags
        self.metaInfo = metaInfo
        self.hls = hls
        self.dash = dash
        self.lbryId = lbryId
        self.uploaderVerified = uploaderVerified
        self.duration = duration
        self.views = views
        self.likes = likes
        self.dislikes = dislikes
        self.audioStreams = audioStreams
        self.videoStreams = videoStreams
        self.relatedStreams = relatedStreams
        self.subtitles = subtitles
        self.livestream = livestream
        self.proxyUrl = proxyUrl
        self.chapters = chapters
        self.uploaderSubscriberCount = uploaderSubscriberCount
        self.previewFrames = previewFrames
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case title, description, uploadTimestamp, uploaded, uploader, uploaderUrl
        case uploaderAvatar, thumbnailUrl, category, license, visibility, tags
        case metaInfo, hls, dash, lbryId, uploaderVerified, duration, views
        case likes, dislikes, audioStreams, videoStreams, relatedStreams
        case subtitles, livestream, proxyUrl, chapters, uploaderSubscriberCount
        case previewFrames
    }
    
    // MARK: - Custom Decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Extract video ID from title or generate one
        self.id = UUID().uuidString // TODO: Extract from URL if available
        
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        
        // Handle date decoding
        if let timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .uploadTimestamp) {
            self.uploadTimestamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.uploadTimestamp = nil
        }
        
        self.uploaded = try container.decodeIfPresent(Int64.self, forKey: .uploaded)
        self.uploader = try container.decode(String.self, forKey: .uploader)
        self.uploaderUrl = try container.decode(String.self, forKey: .uploaderUrl)
        self.uploaderAvatar = try container.decodeIfPresent(String.self, forKey: .uploaderAvatar)
        self.thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
        self.category = try container.decode(String.self, forKey: .category)
        self.license = try container.decodeIfPresent(String.self, forKey: .license) ?? "YouTube licence"
        self.visibility = try container.decodeIfPresent(String.self, forKey: .visibility) ?? "public"
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.metaInfo = try container.decodeIfPresent([MetaInfo].self, forKey: .metaInfo) ?? []
        self.hls = try container.decodeIfPresent(String.self, forKey: .hls)
        self.dash = try container.decodeIfPresent(String.self, forKey: .dash)
        self.lbryId = try container.decodeIfPresent(String.self, forKey: .lbryId)
        self.uploaderVerified = try container.decode(Bool.self, forKey: .uploaderVerified)
        self.duration = try container.decode(Int64.self, forKey: .duration)
        self.views = try container.decodeIfPresent(Int64.self, forKey: .views) ?? 0
        self.likes = try container.decodeIfPresent(Int64.self, forKey: .likes) ?? 0
        self.dislikes = try container.decodeIfPresent(Int64.self, forKey: .dislikes) ?? 0
        self.audioStreams = try container.decodeIfPresent([PipedStream].self, forKey: .audioStreams) ?? []
        self.videoStreams = try container.decodeIfPresent([PipedStream].self, forKey: .videoStreams) ?? []
        self.relatedStreams = try container.decodeIfPresent([StreamItem].self, forKey: .relatedStreams) ?? []
        self.subtitles = try container.decodeIfPresent([Subtitle].self, forKey: .subtitles) ?? []
        self.livestream = try container.decodeIfPresent(Bool.self, forKey: .livestream) ?? false
        self.proxyUrl = try container.decodeIfPresent(String.self, forKey: .proxyUrl)
        self.chapters = try container.decodeIfPresent([ChapterSegment].self, forKey: .chapters) ?? []
        self.uploaderSubscriberCount = try container.decodeIfPresent(Int64.self, forKey: .uploaderSubscriberCount) ?? 0
        self.previewFrames = try container.decodeIfPresent([PreviewFrames].self, forKey: .previewFrames) ?? []
    }
    
    // MARK: - Helper Methods
    public func toStreamItem(videoId: String) -> StreamItem {
        return StreamItem(
            id: videoId,
            url: videoId,
            title: title,
            thumbnail: thumbnailUrl,
            uploaderName: uploader,
            uploaderUrl: uploaderUrl,
            uploaderAvatar: uploaderAvatar,
            uploadedDate: uploadTimestamp?.description,
            uploaded: uploaded ?? uploadTimestamp?.timeIntervalSince1970.magnitude ?? 0,
            duration: duration,
            views: views,
            uploaderVerified: uploaderVerified,
            shortDescription: description
        )
    }
    
    // MARK: - Constants
    public static let categoryMusic = "Music"
}

// MARK: - Supporting Models
public struct MetaInfo: Codable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public struct PipedStream: Codable {
    public let url: String
    public let format: String
    public let quality: String
    public let mimeType: String?
    public let codec: String?
    public let audioTrackId: String?
    public let audioTrackLocale: String?
    public let audioTrackName: String?
    public let videoOnly: Bool?
    public let bitrate: Int?
    public let initStart: Int?
    public let initEnd: Int?
    public let indexStart: Int?
    public let indexEnd: Int?
    public let width: Int?
    public let height: Int?
    public let fps: Int?
    
    public init(
        url: String,
        format: String,
        quality: String,
        mimeType: String? = nil,
        codec: String? = nil,
        audioTrackId: String? = nil,
        audioTrackLocale: String? = nil,
        audioTrackName: String? = nil,
        videoOnly: Bool? = nil,
        bitrate: Int? = nil,
        initStart: Int? = nil,
        initEnd: Int? = nil,
        indexStart: Int? = nil,
        indexEnd: Int? = nil,
        width: Int? = nil,
        height: Int? = nil,
        fps: Int? = nil
    ) {
        self.url = url
        self.format = format
        self.quality = quality
        self.mimeType = mimeType
        self.codec = codec
        self.audioTrackId = audioTrackId
        self.audioTrackLocale = audioTrackLocale
        self.audioTrackName = audioTrackName
        self.videoOnly = videoOnly
        self.bitrate = bitrate
        self.initStart = initStart
        self.initEnd = initEnd
        self.indexStart = indexStart
        self.indexEnd = indexEnd
        self.width = width
        self.height = height
        self.fps = fps
    }
}

public struct Subtitle: Codable {
    public let url: String
    public let mimeType: String
    public let name: String
    public let code: String
    public let autoGenerated: Bool
    
    public init(url: String, mimeType: String, name: String, code: String, autoGenerated: Bool) {
        self.url = url
        self.mimeType = mimeType
        self.name = name
        self.code = code
        self.autoGenerated = autoGenerated
    }
}

public struct ChapterSegment: Codable {
    public let title: String
    public let image: String
    public let start: Int64
    public let end: Int64
    
    public init(title: String, image: String, start: Int64, end: Int64) {
        self.title = title
        self.image = image
        self.start = start
        self.end = end
    }
}

public struct PreviewFrames: Codable {
    public let urls: [String]
    public let frameWidth: Int
    public let frameHeight: Int
    public let totalCount: Int
    public let durationPerFrame: Int
    public let framesPerPageX: Int
    public let framesPerPageY: Int
    
    public init(
        urls: [String],
        frameWidth: Int,
        frameHeight: Int,
        totalCount: Int,
        durationPerFrame: Int,
        framesPerPageX: Int,
        framesPerPageY: Int
    ) {
        self.urls = urls
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.totalCount = totalCount
        self.durationPerFrame = durationPerFrame
        self.framesPerPageX = framesPerPageX
        self.framesPerPageY = framesPerPageY
    }
}