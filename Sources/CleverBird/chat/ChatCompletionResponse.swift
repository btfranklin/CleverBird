//  Created by B.T. Franklin on 5/5/23

import Foundation

public struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}

public struct ChatCompletionResponse: Codable, Identifiable {

    public struct Choice: Codable {

        enum FinishReason: String, Codable {
            case stop
            case maxTokens
            case functionCall = "function_call"
        }

        let message: ChatMessage
        let finishReason: FinishReason
        let functionCall: FunctionCall?

        enum CodingKeys: String, CodingKey {
            case message
            case finishReason
            case functionCall
        }
    }

    let choices: [Choice]
    let usage: Usage
    public let id: String

    enum CodingKeys: String, CodingKey {
        case choices
        case usage
        case id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)

        var choicesContainer = try container.nestedUnkeyedContainer(forKey: .choices)
        var choices: [Choice] = []
        while !choicesContainer.isAtEnd {
            let choiceContainer = try choicesContainer.nestedContainer(keyedBy: Choice.CodingKeys.self)

            var message = try choiceContainer.decode(ChatMessage.self, forKey: .message)
            message.id = id

            let finishReason = try choiceContainer.decode(Choice.FinishReason.self, forKey: .finishReason)

            let functionCall = try choiceContainer.decodeIfPresent(FunctionCall.self, forKey: .functionCall)

            let choice = Choice(message: message, finishReason: finishReason, functionCall: functionCall)
            choices.append(choice)
        }
        self.choices = choices

        self.usage = try container.decode(Usage.self, forKey: .usage)
    }

}
