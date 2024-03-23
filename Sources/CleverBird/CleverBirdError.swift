import Foundation

public enum CleverBirdError: Error, Equatable {
    case requestFailed(message: String)
    case unauthorized(message: String)
    case forbidden(message: String)
    case proxyAuthenticationRequired(message: String)
    case responseParsingFailed(message: String)
    case tokenEncoderCreationFailed(message: String)
    case tokenEncodingError(message: String)
    case invalidMessageContent
    case invalidFunctionMessage
    case invalidEmbeddingRequest(message: String)
    case tooManyRequests
}

extension CleverBirdError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .requestFailed(message: let message):
            "Request failed. \(message)"
        case .unauthorized(message: let message):
            "Unauthorized. \(message)"
        case .forbidden(message: let message):
            "Forbidden. \(message)"
        case .proxyAuthenticationRequired(message: let message):
            "Proxy Authentication Required. \(message)"
        case .responseParsingFailed(message: let message):
            "Parsing failed. \(message)"
        case .tokenEncoderCreationFailed(message: let message):
            "Encoding failed. \(message)"
        case .tokenEncodingError(message: let message):
            "Token encoding failed. \(message)"
        case .invalidMessageContent:
            "Invalid message content"
        case .invalidFunctionMessage:
            "Invalid function message"
        case .invalidEmbeddingRequest(message: let message):
            "Invalid embeddings request. \(message)"
        case .tooManyRequests:
            "Too many requests"
        }
    }
}

extension CleverBirdError {
    init(statusCode: Int) {
        switch statusCode {
        case 401:
            self = .unauthorized(message: "")
        case 403:
            self = .forbidden(message: "")
        case 407:
            self = .proxyAuthenticationRequired(message: "")
        case 429:
            self = .tooManyRequests
        default:
            self = .requestFailed(message: "Response status code: \(statusCode)")
        }
    }
}
