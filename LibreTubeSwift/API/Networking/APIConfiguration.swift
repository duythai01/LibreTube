import Foundation
import Combine

/// Cấu hình chính cho API LibreTube
public struct APIConfiguration {
    
    /// URL API mặc định cho Piped
    public static let defaultPipedAPIURL = "https://pipedapi.kavin.rocks"
    
    /// URL API hiện tại được sử dụng
    public static var currentAPIURL: String {
        // TODO: Implement preference helper để lấy URL từ settings
        return defaultPipedAPIURL
    }
    
    /// URL cho authentication API
    public static var authAPIURL: String {
        // TODO: Implement logic để lấy auth URL từ preferences
        return currentAPIURL
    }
    
    /// Cấu hình cho HTTP client
    public static let httpConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        #if DEBUG
        // Thêm logging cho debug mode
        config.httpAdditionalHeaders = ["User-Agent": "LibreTubeSwift/1.0"]
        #endif
        
        return config
    }()
    
    /// Shared URLSession instance
    public static let sharedSession = URLSession(configuration: httpConfiguration)
    
    /// JSON Decoder với cấu hình tùy chỉnh
    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    /// JSON Encoder với cấu hình tùy chỉnh
    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

/// Protocol cho API endpoints
public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
}

/// HTTP Methods
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

/// API Error types
public enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case httpError(Int, String)
    case unauthorized
    case serverError
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error"
        }
    }
}