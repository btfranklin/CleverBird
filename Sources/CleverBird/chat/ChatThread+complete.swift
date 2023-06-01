//  Created by B.T. Franklin on 5/5/23

extension ChatThread {
    public func complete(model: Model? = nil,
                         temperature: Percentage? = nil,
                         topP: Percentage? = nil,
                         stop: [String]? = nil,
                         maxTokens: Int? = nil,
                         presencePenalty: Penalty? = nil,
                         frequencyPenalty: Penalty? = nil) async throws -> ChatMessage {

        let requestBody = ChatCompletionRequestParameters(
            model: model ?? self.model,
            temperature: temperature ?? self.temperature,
            topP: topP ?? self.topP,
            stop: stop ?? self.stop,
            maxTokens: maxTokens ?? self.maxTokens,
            presencePenalty: presencePenalty ?? self.presencePenalty,
            frequencyPenalty: frequencyPenalty ?? self.frequencyPenalty,
            user: self.user,
            messages: self.messages
        )

        do {
            let request = try await self.connection.createRequest(for: requestBody)
            let response = try await self.connection.client.send(request)
            let completion = response.value
            guard let firstChoiceMessage = completion.choices.first?.message else {
                throw CleverBirdError.responseParsingFailed(message: "No message choice was available in completion response.")
            }

            // Append the response message to the thread
            _ = addMessage(firstChoiceMessage)

            return firstChoiceMessage
        } catch {
            throw CleverBirdError.requestFailed(message: error.localizedDescription)
        }
    }
}
