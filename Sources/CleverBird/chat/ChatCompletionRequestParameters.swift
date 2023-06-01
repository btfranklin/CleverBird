//  Created by B.T. Franklin on 4/15/23

public struct ChatCompletionRequestParameters: Codable {
    public let model: Model
    public let temperature: Percentage
    public let topP: Percentage?
    public let stream: Bool
    public let stop: [String]?
    public let maxTokens: Int?
    public let presencePenalty: Penalty?
    public let frequencyPenalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]

    public init(model: Model,
                temperature: Percentage,
                topP: Percentage? = nil,
                stream: Bool = false,
                stop: [String]? = nil,
                maxTokens: Int? = nil,
                presencePenalty: Penalty? = nil,
                frequencyPenalty: Penalty? = nil,
                user: String? = nil,
                messages: [ChatMessage]) {
        self.model = model
        self.temperature = temperature
        self.topP = topP
        self.stream = stream
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.user = user
        self.messages = messages
    }
}
