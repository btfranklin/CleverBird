//  Created by B.T. Franklin on 5/5/23

extension ChatThread {
    public func complete(using connection: OpenAIAPIConnection,
                         model: ChatModel = .gpt4o,
                         temperature: Percentage = 0.7,
                         topP: Percentage? = nil,
                         stop: [String]? = nil,
                         maxTokens: Int? = nil,
                         presencePenalty: Penalty? = nil,
                         frequencyPenalty: Penalty? = nil,
                         functions: [Function]? = nil,
                         functionCallMode: FunctionCallMode? = nil) async throws -> ChatMessage {
        try await completeIncludeUsage(using: connection,
                                    model: model,
                                    temperature: temperature,
                                    topP: topP,
                                    stop: stop,
                                    maxTokens: maxTokens,
                                    presencePenalty: presencePenalty,
                                    frequencyPenalty: frequencyPenalty,
                                    functions: functions,
                                    functionCallMode: functionCallMode).0
    }
    
    public func completeIncludeUsage(using connection: OpenAIAPIConnection,
                         model: ChatModel = .gpt4o,
                         temperature: Percentage = 0.7,
                         topP: Percentage? = nil,
                         stop: [String]? = nil,
                         maxTokens: Int? = nil,
                         presencePenalty: Penalty? = nil,
                         frequencyPenalty: Penalty? = nil,
                         functions: [Function]? = nil,
                         functionCallMode: FunctionCallMode? = nil) async throws -> (ChatMessage, Usage) {
        let requestBody = ChatCompletionRequestParameters(
            model: model,
            temperature: temperature,
            topP: topP,
            stop: stop,
            maxTokens: maxTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            user: self.user,
            messages: self.messages,
            functions: functions ?? self.functions,
            functionCallMode: functionCallMode
        )

        do {
            // Set the functions in the FunctionRegistry before the request
            if let functions = requestBody.functions {
                FunctionRegistry.shared.setFunctions(functions)
            }

            // ...and be sure to clear them at the end.
            defer {
                FunctionRegistry.shared.clearFunctions()
            }

            let request = try await connection.createChatCompletionRequest(for: requestBody)
            let response = try await connection.client.send(request)
            let completion = response.value
            guard let firstChoiceMessage = completion.choices.first?.message else {
                throw CleverBirdError.responseParsingFailed(message: "No message choice was available in completion response.")
            }

            // Append the response message to the thread
            addMessage(firstChoiceMessage)

            return (firstChoiceMessage, completion.usage)

        } catch {
            throw CleverBirdError.requestFailed(message: error.localizedDescription)
        }
    }
}
