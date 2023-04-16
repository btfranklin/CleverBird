//  Created by B.T. Franklin on 4/15/23

// The overall structure of these is:
// ChatCompletionResponse
//   - [ChatChoice]
//     - ChatMessage
//       - ChatRole
//
// ChatCompletionRequest
//   - [ChatMessage]
//     - ChatRole

public struct ChatCompletionResponse: Codable {
    public let model: String
    public let choices: [ChatChoice]
}

public struct ChatCompletionRequest: Codable {
    public let model: String
    public let temperature: Percentage
    public let top_p: Percentage?
    public let n: Int?
    public let stop: [String]?
    public let presence_penalty: Penalty?
    public let frequency_penalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]
}

public struct ChatChoice: Codable {
    public let message: ChatMessage
    public let index: Int
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
