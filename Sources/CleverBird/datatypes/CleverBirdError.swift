import Foundation

public enum CleverBirdError: Error {
    case requestFailed(message: String)
    case responseParsingFailed(message: String)
    case tokenEncoderCreationFailed(message: String)
    case tokenEncodingError(message: String)
}
