import Foundation
import Combine

/// External API Service converted from ExternalApi.kt
public class ExternalAPIService {
    
    // MARK: - Constants
    private static let GITHUB_API_URL = "https://api.github.com/repos/libre-tube/LibreTube/releases/latest"
    private static let SB_API_URL = "https://sponsor.ajay.app"
    private static let RYD_API_URL = "https://returnyoutubedislikeapi.com"
    private static let GOOGLE_API_KEY = "AIzaSyDyT5W0Jh49F30Pqqtyfdf7pDLFKLJoAnw"
    public static let USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.3"
    private static let PIPED_INSTANCES_URL = "https://piped-instances.kavin.rocks"
    private static let PIPED_INSTANCES_MARKDOWN_URL = "https://raw.githubusercontent.com/TeamPiped/documentation/refs/heads/main/content/docs/public-instances/index.md"
    
    // MARK: - Singleton
    public static let shared = ExternalAPIService()
    private init() {}
    
    // MARK: - Instance Management
    public func getInstances(url: String = PIPED_INSTANCES_URL) async throws -> [PipedInstance] {
        let request = URLRequest(url: URL(string: url)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([PipedInstance].self, from: data)
    }
    
    public func getInstancesMarkdown(url: String = PIPED_INSTANCES_MARKDOWN_URL) async throws -> String {
        let request = URLRequest(url: URL(string: url)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public func getInstanceConfig(url: String) async throws -> PipedConfig {
        let configURL = URL(string: url)!.appendingPathComponent("config")
        let request = URLRequest(url: configURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(PipedConfig.self, from: data)
    }
    
    // MARK: - GitHub API
    public func getLatestRelease() async throws -> UpdateInfo {
        let request = URLRequest(url: URL(string: GITHUB_API_URL)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(UpdateInfo.self, from: data)
    }
    
    // MARK: - Return YouTube Dislike API
    public func getVotes(videoId: String) async throws -> VoteInfo {
        let url = URL(string: "\(RYD_API_URL)/votes")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "videoId", value: videoId)]
        
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(VoteInfo.self, from: data)
    }
    
    // MARK: - SponsorBlock API
    public func submitSegment(
        videoId: String,
        userID: String,
        userAgent: String,
        startTime: Float,
        endTime: Float,
        category: String,
        duration: Float? = nil,
        description: String = ""
    ) async throws -> [SubmitSegmentResponse] {
        let url = URL(string: "\(SB_API_URL)/api/skipSegments")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "videoID", value: videoId),
            URLQueryItem(name: "userID", value: userID),
            URLQueryItem(name: "userAgent", value: userAgent),
            URLQueryItem(name: "startTime", value: String(startTime)),
            URLQueryItem(name: "endTime", value: String(endTime)),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "description", value: description)
        ]
        
        if let duration = duration {
            components.queryItems?.append(URLQueryItem(name: "duration", value: String(duration)))
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([SubmitSegmentResponse].self, from: data)
    }
    
    public func getSegments(
        videoId: String,
        category: [String],
        actionType: [String]? = nil
    ) async throws -> [SegmentData] {
        let url = URL(string: "\(SB_API_URL)/api/skipSegments/\(videoId)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "category", value: category.joined(separator: ","))]
        
        if let actionType = actionType {
            components.queryItems?.append(URLQueryItem(name: "actionType", value: actionType.joined(separator: ",")))
        }
        
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([SegmentData].self, from: data)
    }
    
    public func submitDeArrow(body: DeArrowBody) async throws {
        let url = URL(string: "\(SB_API_URL)/api/branding")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    public func voteOnSponsorTime(uuid: String, userID: String, score: Int) async throws {
        let url = URL(string: "\(SB_API_URL)/api/voteOnSponsorTime")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "UUID", value: uuid),
            URLQueryItem(name: "userID", value: userID),
            URLQueryItem(name: "type", value: String(score))
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    public func getDeArrowContent(videoId: String) async throws -> [String: DeArrowContent] {
        let url = URL(string: "\(SB_API_URL)/api/branding/\(videoId)")!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([String: DeArrowContent].self, from: data)
    }
    
    // MARK: - BotGuard API
    public func botguardRequest(url: String, jsonPayload: [String]) async throws -> Any {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json+protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue(GOOGLE_API_KEY, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("grpc-web-javascript/0.1", forHTTPHeaderField: "x-user-agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data)
    }
}

// MARK: - Error Types
public enum APIError: Error {
    case invalidResponse
    case decodingError
    case networkError
}