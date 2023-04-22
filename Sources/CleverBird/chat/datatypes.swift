//  Created by B.T. Franklin on 4/15/23

public struct ChatCompletionRequest: Codable {
    public let model: Model
    public let temperature: Percentage
    public let topP: Percentage?
    public let stop: [String]?
    public let presencePenalty: Penalty?
    public let frequencyPenalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]
}

public struct ChatMessage: Codable {
    public enum Role: String, Codable {
        case system
        case user
        case assistant
    }
    public let role: Role
    public let content: String
}
