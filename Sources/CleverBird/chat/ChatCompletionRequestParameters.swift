//  Created by B.T. Franklin on 4/15/23

public struct ChatCompletionRequestParameters: Codable {
    public let model: ChatModel
    public let temperature: Percentage
    public let topP: Percentage?
    public let stream: Bool
    public let stop: [String]?
    public let maxTokens: Int?
    public let presencePenalty: Penalty?
    public let frequencyPenalty: Penalty?
    public let user: String?
    public let messages: [ChatMessage]
    public let functions: [Function]?
    public let functionCallMode: FunctionCallMode?

    public init(model: ChatModel,
                temperature: Percentage,
                topP: Percentage? = nil,
                stream: Bool = false,
                stop: [String]? = nil,
                maxTokens: Int? = nil,
                presencePenalty: Penalty? = nil,
                frequencyPenalty: Penalty? = nil,
                user: String? = nil,
                messages: [ChatMessage],
                functions: [Function]? = nil,
                functionCallMode: FunctionCallMode? = nil) {
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
        self.functions = functions
        self.functionCallMode = functionCallMode
    }
}
