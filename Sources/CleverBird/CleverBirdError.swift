import Foundation

public enum CleverBirdError: Error, Equatable {
    case requestFailed(message: String)
    case responseParsingFailed(message: String)
    case tokenEncoderCreationFailed(message: String)
    case tokenEncodingError(message: String)
    case invalidMessageContent
    case invalidFunctionMessage
    case invalidEmbeddingRequest(message: String)
}
