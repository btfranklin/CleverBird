//  Created by B.T. Franklin on 5/5/23

import Foundation

extension ChatThread {
    public func completeWithStreaming() async throws -> AsyncThrowingStream<String, Swift.Error> {

        let requestBody = ChatCompletionRequestParameters(
            model: self.model,
            temperature: self.temperature,
            topP: self.topP,
            stream: true,
            stop: self.stop,
            presencePenalty: self.presencePenalty,
            frequencyPenalty: self.frequencyPenalty,
            user: self.user,
            messages: self.messages
        )

        // Define the callback closure that appends the message to the chat thread
        let addStreamedMessageToThread: (ChatMessage) -> Void = { message in
            _ = self.addMessage(message)
        }

        let asyncByteStream = try await self.connection.createAsyncByteStream(for: requestBody)
        return AsyncThrowingStream { continuation in
            Task {

                var responseMessageRole: ChatMessage.Role?
                var responseMessageContent: String?

                do {
                    for try await line in asyncByteStream.lines {
                        guard let responseChunk = ChatStreamedResponseChunk.decode(from: line) else {
                            break
                        }

                        if let deltaRole = responseChunk.choices.first?.delta.role {
                            responseMessageRole = deltaRole
                            continue
                        }

                        guard let delta = responseChunk.choices.first?.delta else {
                            continue
                        }

                        guard let deltaContent = delta.content else {
                            continue
                        }

                        if let currentMessageContent = responseMessageContent {
                            responseMessageContent = currentMessageContent + deltaContent
                        } else {
                            responseMessageContent = deltaContent
                        }
                        continuation.yield(deltaContent)
                    }
                } catch {
                    throw CleverBirdError.responseParsingFailed
                }

                if let responseMessageRole, let responseMessageContent {
                    addStreamedMessageToThread(ChatMessage(role: responseMessageRole, content: responseMessageContent))
                }
                continuation.finish()
            }
        }
    }

}
