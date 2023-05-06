//  Created by B.T. Franklin on 5/5/23

extension OpenAIChatThread {
    public func tokenCount() -> Int {

        let tokenEncoder: TokenEncoder
        do {
            tokenEncoder = try TokenEncoder()
        } catch {
            logger("Unable to create token encoder: \(error)")
            return -1
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
                logger("Error encoding text: \(error)")
            }
        }

        numTokens += 3  // every reply is primed with assistant

        return numTokens
    }
}
