//  Created by B.T. Franklin on 5/5/23

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
                let contentTokens = try tokenEncoder.encode(text: message.content).count

                numTokens += roleTokens + contentTokens + tokensPerMessage
            } catch {
                throw CleverBirdError.tokenEncodingError(message: error.localizedDescription)
            }
        }

        numTokens += 3  // every reply is primed with "assistant"

        return numTokens
    }
}
