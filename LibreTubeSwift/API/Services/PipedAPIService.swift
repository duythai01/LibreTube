import Foundation
import Combine

/// Service để gọi các API của Piped
public protocol PipedAPIServiceProtocol {
    
    // MARK: - Trending & Search
    func getTrending(region: String) -> AnyPublisher<[StreamItem], APIError>
    func getSearchResults(searchQuery: String, filter: String) -> AnyPublisher<SearchResult, APIError>
    func getSearchResultsNextPage(searchQuery: String, filter: String, nextPage: String) -> AnyPublisher<SearchResult, APIError>
    func getSuggestions(query: String) -> AnyPublisher<[String], APIError>
    
    // MARK: - Video Streams
    func getStreams(videoId: String) -> AnyPublisher<Streams, APIError>
    func getComments(videoId: String) -> AnyPublisher<CommentsPage, APIError>
    func getCommentsNextPage(videoId: String, nextPage: String) -> AnyPublisher<CommentsPage, APIError>
    
    // MARK: - Sponsors & DeArrow
    func getSegments(videoId: String, category: String, actionType: String?) -> AnyPublisher<SegmentData, APIError>
    func getDeArrowContent(videoIds: String) -> AnyPublisher<[String: DeArrowContent], APIError>
    
    // MARK: - Channels
    func getChannel(channelId: String) -> AnyPublisher<Channel, APIError>
    func getChannelByName(channelName: String) -> AnyPublisher<Channel, APIError>
    func getChannelNextPage(channelId: String, nextPage: String) -> AnyPublisher<Channel, APIError>
    func getChannelTab(data: String, nextPage: String?) -> AnyPublisher<ChannelTabResponse, APIError>
    
    // MARK: - Playlists
    func getPlaylist(playlistId: String) -> AnyPublisher<Playlist, APIError>
    func getPlaylistNextPage(playlistId: String, nextPage: String) -> AnyPublisher<Playlist, APIError>
}

/// Implementation của PipedAPIService
public class PipedAPIService: PipedAPIServiceProtocol {
    
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    public init(
        baseURL: String = APIConfiguration.currentAPIURL,
        session: URLSession = APIConfiguration.sharedSession,
        decoder: JSONDecoder = APIConfiguration.jsonDecoder,
        encoder: JSONEncoder = APIConfiguration.jsonEncoder
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
    
    // MARK: - Trending & Search
    public func getTrending(region: String) -> AnyPublisher<[StreamItem], APIError> {
        let endpoint = TrendingEndpoint(region: region)
        return performRequest(endpoint: endpoint)
    }
    
    public func getSearchResults(searchQuery: String, filter: String) -> AnyPublisher<SearchResult, APIError> {
        let endpoint = SearchEndpoint(query: searchQuery, filter: filter)
        return performRequest(endpoint: endpoint)
    }
    
    public func getSearchResultsNextPage(searchQuery: String, filter: String, nextPage: String) -> AnyPublisher<SearchResult, APIError> {
        let endpoint = SearchNextPageEndpoint(query: searchQuery, filter: filter, nextPage: nextPage)
        return performRequest(endpoint: endpoint)
    }
    
    public func getSuggestions(query: String) -> AnyPublisher<[String], APIError> {
        let endpoint = SuggestionsEndpoint(query: query)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Video Streams
    public func getStreams(videoId: String) -> AnyPublisher<Streams, APIError> {
        let endpoint = StreamsEndpoint(videoId: videoId)
        return performRequest(endpoint: endpoint)
    }
    
    public func getComments(videoId: String) -> AnyPublisher<CommentsPage, APIError> {
        let endpoint = CommentsEndpoint(videoId: videoId)
        return performRequest(endpoint: endpoint)
    }
    
    public func getCommentsNextPage(videoId: String, nextPage: String) -> AnyPublisher<CommentsPage, APIError> {
        let endpoint = CommentsNextPageEndpoint(videoId: videoId, nextPage: nextPage)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Sponsors & DeArrow
    public func getSegments(videoId: String, category: String, actionType: String?) -> AnyPublisher<SegmentData, APIError> {
        let endpoint = SegmentsEndpoint(videoId: videoId, category: category, actionType: actionType)
        return performRequest(endpoint: endpoint)
    }
    
    public func getDeArrowContent(videoIds: String) -> AnyPublisher<[String: DeArrowContent], APIError> {
        let endpoint = DeArrowEndpoint(videoIds: videoIds)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Channels
    public func getChannel(channelId: String) -> AnyPublisher<Channel, APIError> {
        let endpoint = ChannelEndpoint(channelId: channelId)
        return performRequest(endpoint: endpoint)
    }
    
    public func getChannelByName(channelName: String) -> AnyPublisher<Channel, APIError> {
        let endpoint = ChannelByNameEndpoint(channelName: channelName)
        return performRequest(endpoint: endpoint)
    }
    
    public func getChannelNextPage(channelId: String, nextPage: String) -> AnyPublisher<Channel, APIError> {
        let endpoint = ChannelNextPageEndpoint(channelId: channelId, nextPage: nextPage)
        return performRequest(endpoint: endpoint)
    }
    
    public func getChannelTab(data: String, nextPage: String?) -> AnyPublisher<ChannelTabResponse, APIError> {
        let endpoint = ChannelTabEndpoint(data: data, nextPage: nextPage)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Playlists
    public func getPlaylist(playlistId: String) -> AnyPublisher<Playlist, APIError> {
        let endpoint = PlaylistEndpoint(playlistId: playlistId)
        return performRequest(endpoint: endpoint)
    }
    
    public func getPlaylistNextPage(playlistId: String, nextPage: String) -> AnyPublisher<Playlist, APIError> {
        let endpoint = PlaylistNextPageEndpoint(playlistId: playlistId, nextPage: nextPage)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Private Methods
    private func performRequest<T: Codable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        guard let url = buildURL(from: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.networkError(NSError(domain: "Invalid response", code: -1))
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.unauthorized
                case 500...599:
                    throw APIError.serverError
                default:
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw APIError.httpError(httpResponse.statusCode, errorMessage)
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func buildURL(from endpoint: APIEndpoint) -> URL? {
        var components = URLComponents(string: endpoint.baseURL + endpoint.path)
        
        if let parameters = endpoint.parameters {
            components?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return components?.url
    }
}

// MARK: - API Endpoints
private struct TrendingEndpoint: APIEndpoint {
    let region: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/trending" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["region": region] }
    var body: Data? { nil }
}

private struct SearchEndpoint: APIEndpoint {
    let query: String
    let filter: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/search" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["q": query, "filter": filter] }
    var body: Data? { nil }
}

private struct SearchNextPageEndpoint: APIEndpoint {
    let query: String
    let filter: String
    let nextPage: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/nextpage/search" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["q": query, "filter": filter, "nextpage": nextPage] }
    var body: Data? { nil }
}

private struct SuggestionsEndpoint: APIEndpoint {
    let query: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/suggestions" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["query": query] }
    var body: Data? { nil }
}

private struct StreamsEndpoint: APIEndpoint {
    let videoId: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/streams/\(videoId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct CommentsEndpoint: APIEndpoint {
    let videoId: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/comments/\(videoId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct CommentsNextPageEndpoint: APIEndpoint {
    let videoId: String
    let nextPage: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/nextpage/comments/\(videoId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["nextpage": nextPage] }
    var body: Data? { nil }
}

private struct SegmentsEndpoint: APIEndpoint {
    let videoId: String
    let category: String
    let actionType: String?
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/sponsors/\(videoId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? {
        var params: [String: Any] = ["category": category]
        if let actionType = actionType {
            params["actionType"] = actionType
        }
        return params
    }
    var body: Data? { nil }
}

private struct DeArrowEndpoint: APIEndpoint {
    let videoIds: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/dearrow" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["videoIds": videoIds] }
    var body: Data? { nil }
}

private struct ChannelEndpoint: APIEndpoint {
    let channelId: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/channel/\(channelId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct ChannelByNameEndpoint: APIEndpoint {
    let channelName: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/user/\(channelName)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct ChannelNextPageEndpoint: APIEndpoint {
    let channelId: String
    let nextPage: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/nextpage/channel/\(channelId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["nextpage": nextPage] }
    var body: Data? { nil }
}

private struct ChannelTabEndpoint: APIEndpoint {
    let data: String
    let nextPage: String?
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/channels/tabs" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? {
        var params: [String: Any] = ["data": data]
        if let nextPage = nextPage {
            params["nextpage"] = nextPage
        }
        return params
    }
    var body: Data? { nil }
}

private struct PlaylistEndpoint: APIEndpoint {
    let playlistId: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/playlists/\(playlistId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct PlaylistNextPageEndpoint: APIEndpoint {
    let playlistId: String
    let nextPage: String
    
    var baseURL: String { APIConfiguration.currentAPIURL }
    var path: String { "/nextpage/playlists/\(playlistId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { ["nextpage": nextPage] }
    var body: Data? { nil }
}