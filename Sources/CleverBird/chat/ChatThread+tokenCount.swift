//  Created by B.T. Franklin on 5/5/23

import Foundation

extension ChatThread {
    public func tokenCount() throws -> Int {

        let tokenEncoder: TokenEncoder
        do {
            tokenEncoder = try TokenEncoder()
        } catch {
            throw CleverBirdError.tokenEncoderCreationFailed(message: error.localizedDescription)
        }

        var tokensPerMessage: Int

        switch self.model {
        case .gpt35Turbo:
            tokensPerMessage = 4
        case .gpt4:
            tokensPerMessage = 3
        }

        var numTokens = 0
        for message in messages {
            do {
                let roleTokens = try tokenEncoder.encode(text: message.role.rawValue).count
                let contentTokens: Int
                if let content = message.content {
                    contentTokens = try tokenEncoder.encode(text: content).count
                } else if let functionCall = message.functionCall {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(functionCall)
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    contentTokens = try tokenEncoder.encode(text: jsonString).count
                } else {
                    contentTokens = 0
                }

                numTokens += roleTokens + contentTokens + tokensPerMessage
            } catch {
                throw CleverBirdError.tokenEncodingError(message: error.localizedDescription)
            }
        }


        numTokens += 3  // every reply is primed with "assistant"

        if let functions {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(functions)
            let jsonString = String(data: jsonData, encoding: .utf8)
            numTokens += try tokenEncoder.encode(text: jsonString!).count
        }

        return numTokens
    }
}
