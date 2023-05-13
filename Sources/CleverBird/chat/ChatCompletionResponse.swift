//  Created by B.T. Franklin on 5/5/23

public struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }
    let choices: [Choice]
    let id: String

    enum CodingKeys: String, CodingKey {
        case choices
        case id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        var choicesContainer = try container.nestedUnkeyedContainer(forKey: .choices)
        var choices = [Choice]()
        while !choicesContainer.isAtEnd {
            let choice = try choicesContainer.decode(Choice.self)
            var message = choice.message
            message.id = id
            choices.append(Choice(message: message))
        }
        self.choices = choices
    }
}
