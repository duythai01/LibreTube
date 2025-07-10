import Foundation

// MARK: - Search Result
public struct SearchResult: Codable {
    public let corrected: Bool
    public let items: [StreamItem]
    public let nextpage: String?
    
    public init(corrected: Bool, items: [StreamItem], nextpage: String?) {
        self.corrected = corrected
        self.items = items
        self.nextpage = nextpage
    }
}

// MARK: - Comments
public struct CommentsPage: Codable {
    public let comments: [Comment]
    public let nextpage: String?
    
    public init(comments: [Comment], nextpage: String?) {
        self.comments = comments
        self.nextpage = nextpage
    }
}

public struct Comment: Codable, Identifiable {
    public let id: String
    public let author: String
    public let authorThumbnails: [String]
    public let authorId: String
    public let authorUrl: String
    public let content: String
    public let published: Int64
    public let publishedText: String
    public let likeCount: Int
    public let isEdited: Bool
    public let isAuthorVerified: Bool
    public let isAuthorOwner: Bool
    public let isAuthorPinned: Bool
    public let replies: [Comment]?
    public let replyCount: Int?
    public let replyToken: String?
    
    public init(
        id: String,
        author: String,
        authorThumbnails: [String],
        authorId: String,
        authorUrl: String,
        content: String,
        published: Int64,
        publishedText: String,
        likeCount: Int,
        isEdited: Bool,
        isAuthorVerified: Bool,
        isAuthorOwner: Bool,
        isAuthorPinned: Bool,
        replies: [Comment]? = nil,
        replyCount: Int? = nil,
        replyToken: String? = nil
    ) {
        self.id = id
        self.author = author
        self.authorThumbnails = authorThumbnails
        self.authorId = authorId
        self.authorUrl = authorUrl
        self.content = content
        self.published = published
        self.publishedText = publishedText
        self.likeCount = likeCount
        self.isEdited = isEdited
        self.isAuthorVerified = isAuthorVerified
        self.isAuthorOwner = isAuthorOwner
        self.isAuthorPinned = isAuthorPinned
        self.replies = replies
        self.replyCount = replyCount
        self.replyToken = replyToken
    }
}

// MARK: - Channel
public struct Channel: Codable, Identifiable {
    public let id: String
    public let name: String
    public let avatar: String?
    public let banner: String?
    public let description: String
    public let subscriberCount: Int64
    public let verified: Bool
    public let relatedStreams: [StreamItem]
    public let tabs: [ChannelTab]
    public let nextpage: String?
    
    public init(
        id: String,
        name: String,
        avatar: String?,
        banner: String?,
        description: String,
        subscriberCount: Int64,
        verified: Bool,
        relatedStreams: [StreamItem],
        tabs: [ChannelTab],
        nextpage: String?
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.banner = banner
        self.description = description
        self.subscriberCount = subscriberCount
        self.verified = verified
        self.relatedStreams = relatedStreams
        self.tabs = tabs
        self.nextpage = nextpage
    }
}

public struct ChannelTab: Codable, Identifiable {
    public let id: String
    public let name: String
    public let data: String
    
    public init(id: String, name: String, data: String) {
        self.id = id
        self.name = name
        self.data = data
    }
}

public struct ChannelTabResponse: Codable {
    public let content: [StreamItem]
    public let nextpage: String?
    
    public init(content: [StreamItem], nextpage: String?) {
        self.content = content
        self.nextpage = nextpage
    }
}

// MARK: - Playlist
public struct Playlist: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let thumbnail: String?
    public let banner: String?
    public let uploader: String
    public let uploaderUrl: String
    public let uploaderAvatar: String?
    public let verified: Bool
    public let videoCount: Int
    public let videos: [StreamItem]
    public let nextpage: String?
    
    public init(
        id: String,
        name: String,
        description: String,
        thumbnail: String?,
        banner: String?,
        uploader: String,
        uploaderUrl: String,
        uploaderAvatar: String?,
        verified: Bool,
        videoCount: Int,
        videos: [StreamItem],
        nextpage: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.banner = banner
        self.uploader = uploader
        self.uploaderUrl = uploaderUrl
        self.uploaderAvatar = uploaderAvatar
        self.verified = verified
        self.videoCount = videoCount
        self.videos = videos
        self.nextpage = nextpage
    }
}

// MARK: - Segment Data (Sponsors)
public struct SegmentData: Codable {
    public let segments: [Segment]
    
    public init(segments: [Segment]) {
        self.segments = segments
    }
}

public struct Segment: Codable, Identifiable {
    public let id: String
    public let category: String
    public let actionType: String
    public let segment: [Int64]
    public let UUID: String
    public let videoDuration: Int64
    public let description: String
    public let locked: Int
    public let votes: Int
    public let background: String
    public let userID: String?
    public let userAgent: String?
    public let shadowHidden: Bool
    public let hidden: Int
    public let reputation: Double
    public let userReputation: Double?
    
    public init(
        id: String,
        category: String,
        actionType: String,
        segment: [Int64],
        UUID: String,
        videoDuration: Int64,
        description: String,
        locked: Int,
        votes: Int,
        background: String,
        userID: String?,
        userAgent: String?,
        shadowHidden: Bool,
        hidden: Int,
        reputation: Double,
        userReputation: Double?
    ) {
        self.id = id
        self.category = category
        self.actionType = actionType
        self.segment = segment
        self.UUID = UUID
        self.videoDuration = videoDuration
        self.description = description
        self.locked = locked
        self.votes = votes
        self.background = background
        self.userID = userID
        self.userAgent = userAgent
        self.shadowHidden = shadowHidden
        self.hidden = hidden
        self.reputation = reputation
        self.userReputation = userReputation
    }
}

// MARK: - DeArrow Content
public struct DeArrowContent: Codable {
    public let titles: [DeArrowTitle]
    public let thumbnails: [DeArrowThumbnail]
    
    public init(titles: [DeArrowTitle], thumbnails: [DeArrowThumbnail]) {
        self.titles = titles
        self.thumbnails = thumbnails
    }
}

public struct DeArrowTitle: Codable {
    public let title: String
    public let original: Bool
    public let votes: Int
    public let locked: Bool
    
    public init(title: String, original: Bool, votes: Int, locked: Bool) {
        self.title = title
        self.original = original
        self.votes = votes
        self.locked = locked
    }
}

public struct DeArrowThumbnail: Codable {
    public let thumbnail: String
    public let original: Bool
    public let votes: Int
    public let locked: Bool
    public let timestamp: String?
    
    public init(thumbnail: String, original: Bool, votes: Int, locked: Bool, timestamp: String?) {
        self.thumbnail = thumbnail
        self.original = original
        self.votes = votes
        self.locked = locked
        self.timestamp = timestamp
    }
}

// MARK: - Vote Info
public struct VoteInfo: Codable {
    public let votes: Int
    public let locked: Bool
    public let reputation: Double
    public let userReputation: Double?
    
    public init(votes: Int, locked: Bool, reputation: Double, userReputation: Double?) {
        self.votes = votes
        self.locked = locked
        self.reputation = reputation
        self.userReputation = userReputation
    }
}

// MARK: - Submit Segment Response
public struct SubmitSegmentResponse: Codable {
    public let UUID: String
    
    public init(UUID: String) {
        self.UUID = UUID
    }
}

// MARK: - Piped Config
public struct PipedConfig: Codable {
    public let authUrl: String
    public let instance: PipedInstance
    
    public init(authUrl: String, instance: PipedInstance) {
        self.authUrl = authUrl
        self.instance = instance
    }
}

public struct PipedInstance: Codable {
    public let name: String
    public let apiUrl: String
    public let locations: String
    public let version: String
    public let upToDate: Bool
    public let cdn: Bool
    public let registered: Int64
    public let lastChecked: Int64
    public let cache: Bool
    public let s3Enabled: Bool
    public let imageProxyUrl: String?
    public let registrationDisabled: Bool
    public let donationUrl: String?
    public let businessEmail: String?
    public let features: [String]
    
    public init(
        name: String,
        apiUrl: String,
        locations: String,
        version: String,
        upToDate: Bool,
        cdn: Bool,
        registered: Int64,
        lastChecked: Int64,
        cache: Bool,
        s3Enabled: Bool,
        imageProxyUrl: String?,
        registrationDisabled: Bool,
        donationUrl: String?,
        businessEmail: String?,
        features: [String]
    ) {
        self.name = name
        self.apiUrl = apiUrl
        self.locations = locations
        self.version = version
        self.upToDate = upToDate
        self.cdn = cdn
        self.registered = registered
        self.lastChecked = lastChecked
        self.cache = cache
        self.s3Enabled = s3Enabled
        self.imageProxyUrl = imageProxyUrl
        self.registrationDisabled = registrationDisabled
        self.donationUrl = donationUrl
        self.businessEmail = businessEmail
        self.features = features
    }
}

// MARK: - Content Item
public struct ContentItem: Codable, Identifiable {
    public let id: String
    public let type: String
    public let name: String?
    public let url: String?
    public let thumbnail: String?
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
    
    public init(
        id: String,
        type: String,
        name: String?,
        url: String?,
        thumbnail: String?,
        uploaderName: String?,
        uploaderUrl: String?,
        uploaderAvatar: String?,
        uploadedDate: String?,
        duration: Int64?,
        views: Int64?,
        uploaderVerified: Bool?,
        uploaded: Int64,
        shortDescription: String?,
        isShort: Bool
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.url = url
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
}

// MARK: - DeArrow Body
public struct DeArrowBody: Codable {
    public let videoID: String
    public let userAgent: String
    public let userID: String?
    public let titles: [DeArrowTitle]?
    public let thumbnails: [DeArrowThumbnail]?
    
    public init(
        videoID: String,
        userAgent: String,
        userID: String?,
        titles: [DeArrowTitle]?,
        thumbnails: [DeArrowThumbnail]?
    ) {
        self.videoID = videoID
        self.userAgent = userAgent
        self.userID = userID
        self.titles = titles
        self.thumbnails = thumbnails
    }
}