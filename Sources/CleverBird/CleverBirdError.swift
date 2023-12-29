import Foundation

public enum CleverBirdError: Error, Equatable {
    case requestFailed(message: String)
    case unauthorized(message: String)
    case responseParsingFailed(message: String)
    case tokenEncoderCreationFailed(message: String)
    case tokenEncodingError(message: String)
    case invalidMessageContent
    case invalidFunctionMessage
    case invalidEmbeddingRequest(message: String)
}

extension CleverBirdError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .requestFailed(message: let message):
            "Request failed: \(message)"
        case .unauthorized(message: let message):
            "Unauthorized: \(message)"
        case .responseParsingFailed(message: let message):
            "Parsing failed: \(message)"
        case .tokenEncoderCreationFailed(message: let message):
            "Encoding failed: \(message)"
        case .tokenEncodingError(message: let message):
            "Token encoding failed: \(message)"
        case .invalidMessageContent:
            "Invalid message content"
        case .invalidFunctionMessage:
            "Invalid function message"
        case .invalidEmbeddingRequest(message: let message):
            "Invalid embeddings request: \(message)"
        }
    }
}
