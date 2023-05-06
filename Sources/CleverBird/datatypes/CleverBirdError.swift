import Foundation

public enum CleverBirdError: Error {
    case requestFailed(message: String)
    case responseParsingFailed
}
