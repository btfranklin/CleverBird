//  Created by B.T. Franklin on 5/5/23

extension ChatThread {
    public func complete() async -> ChatMessage? {

        let requestBody = ChatCompletionRequestParameters(
            model: self.model,
            temperature: self.temperature,
            topP: self.topP,
            stop: self.stop,
            presencePenalty: self.presencePenalty,
            frequencyPenalty: self.frequencyPenalty,
            user: self.user,
            messages: self.messages
        )

        do {
            let request = try await self.connection.createRequest(for: requestBody)
            let response = try await self.connection.client.send(request)
            let completion = response.value
            let firstChoiceMessage = completion.choices.first?.message

            // Append the response message to the thread
            if let firstChoiceMessage {
                _ = addMessage(firstChoiceMessage)
            }

            return firstChoiceMessage
        } catch {
            logger("Error executing request: \(error.localizedDescription)")
            return nil
        }
    }
}
