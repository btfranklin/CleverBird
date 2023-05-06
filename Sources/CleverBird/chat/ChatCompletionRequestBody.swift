//  Created by B.T. Franklin on 4/15/23

public struct ChatCompletionRequestBody: Codable {
    public let model: Model
    public let temperature: Percentage
    public let topP: Percentage?
    public let stop: [String]?
    public let presencePenalty: Penalty?
    public let frequencyPenalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]

    public init(model: Model,
                temperature: Percentage,
                topP: Percentage? = nil,
                stop: [String]? = nil,
                presencePenalty: Penalty? = nil,
                frequencyPenalty: Penalty? = nil,
                user: String? = nil,
                messages: [ChatMessage]) {
        self.model = model
        self.temperature = temperature
        self.topP = topP
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.user = user
        self.messages = messages
    }
}
