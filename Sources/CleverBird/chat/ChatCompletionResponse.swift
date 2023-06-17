//  Created by B.T. Franklin on 5/5/23

struct ChatCompletionResponse: Codable, Identifiable {

    struct Choice: Codable {
        let message: ChatMessage
        let functionCall: FunctionCall?

        enum CodingKeys: String, CodingKey {
            case message
            case functionCall
        }
    }
    let choices: [Choice]
    let id: String

    enum CodingKeys: String, CodingKey {
        case choices
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        var choicesContainer = try container.nestedUnkeyedContainer(forKey: .choices)
        var choices: [Choice] = []
        while !choicesContainer.isAtEnd {
            let choiceContainer = try choicesContainer.nestedContainer(keyedBy: Choice.CodingKeys.self)
            var message = try choiceContainer.decode(ChatMessage.self, forKey: .message)
            let functionCall = try choiceContainer.decodeIfPresent(FunctionCall.self, forKey: .functionCall)
            message.id = id
            let choice = Choice(message: message, functionCall: functionCall)
            choices.append(choice)
        }
        self.choices = choices
    }

}
