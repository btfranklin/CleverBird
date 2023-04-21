//  Created by B.T. Franklin on 4/15/23

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }
    let choices: [Choice]
}

public struct ChatCompletionRequest: Codable {
    public let model: Model
    public let temperature: Percentage
    public let top_p: Percentage?
    public let stop: [String]?
    public let presence_penalty: Penalty?
    public let frequency_penalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]
}

public struct ChatMessage: Codable {
    public let role: ChatRole
    public let content: String
}

public enum ChatRole: String, Codable {
    case system
    case user
    case assistant
}
