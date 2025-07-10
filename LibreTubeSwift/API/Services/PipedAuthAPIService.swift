import Foundation
import Combine

/// Service để gọi các API authentication của Piped
public protocol PipedAuthAPIServiceProtocol {
    
    // MARK: - Authentication
    func login(credentials: LoginCredentials) -> AnyPublisher<Token, APIError>
    func register(credentials: LoginCredentials) -> AnyPublisher<Token, APIError>
    func deleteAccount(token: String, password: String) -> AnyPublisher<Void, APIError>
    
    // MARK: - Feed
    func getFeed(token: String?) -> AnyPublisher<[StreamItem], APIError>
    func getUnauthenticatedFeed(channels: [String]) -> AnyPublisher<[StreamItem], APIError>
    
    // MARK: - Subscriptions
    func isSubscribed(channelId: String, token: String) -> AnyPublisher<Subscribed, APIError>
    func getSubscriptions(token: String) -> AnyPublisher<[Subscription], APIError>
    func getUnauthenticatedSubscriptions(channels: [String]) -> AnyPublisher<[Subscription], APIError>
    func subscribe(channelId: String, token: String) -> AnyPublisher<Message, APIError>
    func unsubscribe(channelId: String, token: String) -> AnyPublisher<Message, APIError>
    func importSubscriptions(channels: [String], token: String, override: Bool) -> AnyPublisher<Message, APIError>
    
    // MARK: - Playlists
    func getUserPlaylists(token: String) -> AnyPublisher<[Playlists], APIError>
    func createPlaylist(name: String, token: String) -> AnyPublisher<EditPlaylistBody, APIError>
    func renamePlaylist(playlistId: String, name: String, token: String) -> AnyPublisher<Message, APIError>
    func changePlaylistDescription(playlistId: String, description: String, token: String) -> AnyPublisher<Message, APIError>
    func deletePlaylist(playlistId: String, token: String) -> AnyPublisher<Message, APIError>
    func addToPlaylist(playlistId: String, videoId: String, token: String) -> AnyPublisher<Message, APIError>
    func removeFromPlaylist(playlistId: String, videoId: String, token: String) -> AnyPublisher<Message, APIError>
    func clonePlaylist(playlistId: String, token: String) -> AnyPublisher<EditPlaylistBody, APIError>
    func getPlaylist(playlistId: String) -> AnyPublisher<Playlist, APIError>
}

/// Implementation của PipedAuthAPIService
public class PipedAuthAPIService: PipedAuthAPIServiceProtocol {
    
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    public init(
        baseURL: String = APIConfiguration.authAPIURL,
        session: URLSession = APIConfiguration.sharedSession,
        decoder: JSONDecoder = APIConfiguration.jsonDecoder,
        encoder: JSONEncoder = APIConfiguration.jsonEncoder
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
    
    // MARK: - Authentication
    public func login(credentials: LoginCredentials) -> AnyPublisher<Token, APIError> {
        let endpoint = LoginEndpoint(credentials: credentials)
        return performRequest(endpoint: endpoint)
    }
    
    public func register(credentials: LoginCredentials) -> AnyPublisher<Token, APIError> {
        let endpoint = RegisterEndpoint(credentials: credentials)
        return performRequest(endpoint: endpoint)
    }
    
    public func deleteAccount(token: String, password: String) -> AnyPublisher<Void, APIError> {
        let endpoint = DeleteAccountEndpoint(token: token, password: password)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Feed
    public func getFeed(token: String?) -> AnyPublisher<[StreamItem], APIError> {
        let endpoint = FeedEndpoint(token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func getUnauthenticatedFeed(channels: [String]) -> AnyPublisher<[StreamItem], APIError> {
        let endpoint = UnauthenticatedFeedEndpoint(channels: channels)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Subscriptions
    public func isSubscribed(channelId: String, token: String) -> AnyPublisher<Subscribed, APIError> {
        let endpoint = IsSubscribedEndpoint(channelId: channelId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func getSubscriptions(token: String) -> AnyPublisher<[Subscription], APIError> {
        let endpoint = SubscriptionsEndpoint(token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func getUnauthenticatedSubscriptions(channels: [String]) -> AnyPublisher<[Subscription], APIError> {
        let endpoint = UnauthenticatedSubscriptionsEndpoint(channels: channels)
        return performRequest(endpoint: endpoint)
    }
    
    public func subscribe(channelId: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = SubscribeEndpoint(channelId: channelId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func unsubscribe(channelId: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = UnsubscribeEndpoint(channelId: channelId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func importSubscriptions(channels: [String], token: String, override: Bool) -> AnyPublisher<Message, APIError> {
        let endpoint = ImportSubscriptionsEndpoint(channels: channels, token: token, override: override)
        return performRequest(endpoint: endpoint)
    }
    
    // MARK: - Playlists
    public func getUserPlaylists(token: String) -> AnyPublisher<[Playlists], APIError> {
        let endpoint = UserPlaylistsEndpoint(token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func createPlaylist(name: String, token: String) -> AnyPublisher<EditPlaylistBody, APIError> {
        let endpoint = CreatePlaylistEndpoint(name: name, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func renamePlaylist(playlistId: String, name: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = RenamePlaylistEndpoint(playlistId: playlistId, name: name, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func changePlaylistDescription(playlistId: String, description: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = ChangePlaylistDescriptionEndpoint(playlistId: playlistId, description: description, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func deletePlaylist(playlistId: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = DeletePlaylistEndpoint(playlistId: playlistId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func addToPlaylist(playlistId: String, videoId: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = AddToPlaylistEndpoint(playlistId: playlistId, videoId: videoId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func removeFromPlaylist(playlistId: String, videoId: String, token: String) -> AnyPublisher<Message, APIError> {
        let endpoint = RemoveFromPlaylistEndpoint(playlistId: playlistId, videoId: videoId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func clonePlaylist(playlistId: String, token: String) -> AnyPublisher<EditPlaylistBody, APIError> {
        let endpoint = ClonePlaylistEndpoint(playlistId: playlistId, token: token)
        return performRequest(endpoint: endpoint)
    }
    
    public func getPlaylist(playlistId: String) -> AnyPublisher<Playlist, APIError> {
        let endpoint = GetPlaylistEndpoint(playlistId: playlistId)
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

// MARK: - Supporting Models
public struct LoginCredentials: Codable {
    public let username: String
    public let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct Token: Codable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

public struct Message: Codable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

public struct Subscribed: Codable {
    public let subscribed: Bool
    
    public init(subscribed: Bool) {
        self.subscribed = subscribed
    }
}

public struct Subscription: Codable, Identifiable {
    public let id: String
    public let name: String
    public let url: String
    public let avatar: String?
    public let verified: Bool
    
    public init(id: String, name: String, url: String, avatar: String?, verified: Bool) {
        self.id = id
        self.name = name
        self.url = url
        self.avatar = avatar
        self.verified = verified
    }
}

public struct Playlists: Codable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct EditPlaylistBody: Codable {
    public let playlistId: String
    public let name: String?
    public let description: String?
    public let videoId: String?
    
    public init(playlistId: String, name: String? = nil, description: String? = nil, videoId: String? = nil) {
        self.playlistId = playlistId
        self.name = name
        self.description = description
        self.videoId = videoId
    }
}

public struct DeleteUserRequest: Codable {
    public let password: String
    
    public init(password: String) {
        self.password = password
    }
}

// MARK: - API Endpoints
private struct LoginEndpoint: APIEndpoint {
    let credentials: LoginCredentials
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/login" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(credentials)
    }
}

private struct RegisterEndpoint: APIEndpoint {
    let credentials: LoginCredentials
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/register" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(credentials)
    }
}

private struct DeleteAccountEndpoint: APIEndpoint {
    let token: String
    let password: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/delete" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { 
        [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
    }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let request = DeleteUserRequest(password: password)
        return try? JSONEncoder().encode(request)
    }
}

private struct FeedEndpoint: APIEndpoint {
    let token: String?
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/feed" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? {
        if let token = token {
            return ["authToken": token]
        }
        return nil
    }
    var body: Data? { nil }
}

private struct UnauthenticatedFeedEndpoint: APIEndpoint {
    let channels: [String]
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/feed/unauthenticated" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(channels)
    }
}

private struct IsSubscribedEndpoint: APIEndpoint {
    let channelId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/subscribed" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { ["channelId": channelId] }
    var body: Data? { nil }
}

private struct SubscriptionsEndpoint: APIEndpoint {
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/subscriptions" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct UnauthenticatedSubscriptionsEndpoint: APIEndpoint {
    let channels: [String]
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/subscriptions/unauthenticated" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(channels)
    }
}

private struct SubscribeEndpoint: APIEndpoint {
    let channelId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/subscribe" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let subscribe = ["channelId": channelId]
        return try? JSONEncoder().encode(subscribe)
    }
}

private struct UnsubscribeEndpoint: APIEndpoint {
    let channelId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/unsubscribe" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let subscribe = ["channelId": channelId]
        return try? JSONEncoder().encode(subscribe)
    }
}

private struct ImportSubscriptionsEndpoint: APIEndpoint {
    let channels: [String]
    let token: String
    let override: Bool
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/import" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { ["override": override] }
    var body: Data? {
        try? JSONEncoder().encode(channels)
    }
}

private struct UserPlaylistsEndpoint: APIEndpoint {
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}

private struct CreatePlaylistEndpoint: APIEndpoint {
    let name: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/create" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let playlist = Playlists(name: name)
        return try? JSONEncoder().encode(playlist)
    }
}

private struct RenamePlaylistEndpoint: APIEndpoint {
    let playlistId: String
    let name: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/rename" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId, name: name)
        return try? JSONEncoder().encode(body)
    }
}

private struct ChangePlaylistDescriptionEndpoint: APIEndpoint {
    let playlistId: String
    let description: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/description" }
    var method: HTTPMethod { .PATCH }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId, description: description)
        return try? JSONEncoder().encode(body)
    }
}

private struct DeletePlaylistEndpoint: APIEndpoint {
    let playlistId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/delete" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId)
        return try? JSONEncoder().encode(body)
    }
}

private struct AddToPlaylistEndpoint: APIEndpoint {
    let playlistId: String
    let videoId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/add" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId, videoId: videoId)
        return try? JSONEncoder().encode(body)
    }
}

private struct RemoveFromPlaylistEndpoint: APIEndpoint {
    let playlistId: String
    let videoId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/user/playlists/remove" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId, videoId: videoId)
        return try? JSONEncoder().encode(body)
    }
}

private struct ClonePlaylistEndpoint: APIEndpoint {
    let playlistId: String
    let token: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/import/playlist" }
    var method: HTTPMethod { .POST }
    var headers: [String: String]? { ["Authorization": token] }
    var parameters: [String: Any]? { nil }
    var body: Data? {
        let body = EditPlaylistBody(playlistId: playlistId)
        return try? JSONEncoder().encode(body)
    }
}

private struct GetPlaylistEndpoint: APIEndpoint {
    let playlistId: String
    
    var baseURL: String { APIConfiguration.authAPIURL }
    var path: String { "/playlists/\(playlistId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}