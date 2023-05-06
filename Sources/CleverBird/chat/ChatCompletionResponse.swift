//  Created by B.T. Franklin on 5/5/23

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }
    let choices: [Choice]
}

