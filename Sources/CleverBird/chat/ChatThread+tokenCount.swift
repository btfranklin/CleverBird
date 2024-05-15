//  Created by B.T. Franklin on 5/5/23

import Foundation

extension ChatThread {
    public func tokenCount(using model: ChatModel = .gpt4) throws -> Int {

        let tokenEncoder: TokenEncoder
        do {
            tokenEncoder = try TokenEncoder()
        } catch {
            throw CleverBirdError.tokenEncoderCreationFailed(message: error.localizedDescription)
        }

        var tokensPerMessage: Int

        switch model {
        case .gpt35Turbo:
            tokensPerMessage = 4
        case .gpt4, .gpt4Turbo:
            tokensPerMessage = 3
        case .gpt4o:
            tokensPerMessage = 3
        case .specific(_):
            tokensPerMessage = 3
        }

        var numTokens = 0
        for message in messages {
            do {
                let roleTokens = try tokenEncoder.encode(text: message.role.rawValue).count
                let contentTokens: Int
                if let content = message.content {
                    switch content {
                    case .text(let text):
                        contentTokens = try tokenEncoder.encode(text: text).count
                    case .media(let media):
                        var count = 0
                        for medium in media {
                            switch medium {
                            case .text(let text):
                                count += try tokenEncoder.encode(text: text).count
                            case .imageUrl(let url):
                                // See https://platform.openai.com/docs/guides/vision/calculating-costs
                                switch url.detail {
                                    // TODO: calculate real values for auto and high
                                case .auto:
                                    count += 1105
                                case .high:
                                    count += 1105
                                case .low:
                                    count += 85
                                case .none:
                                    count += 1105
                                }
                            }
                        }
                        contentTokens = count
                    }
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
