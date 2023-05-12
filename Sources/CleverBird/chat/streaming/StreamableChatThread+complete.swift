//  Created by B.T. Franklin on 5/5/23

import Foundation

extension StreamableChatThread {

    public func complete() async throws -> AsyncThrowingStream<String, Swift.Error> {

        let requestBody = ChatCompletionRequestParameters(
            model: self.chatThread.model,
            temperature: self.chatThread.temperature,
            topP: self.chatThread.topP,
            stream: true,
            stop: self.chatThread.stop,
            presencePenalty: self.chatThread.presencePenalty,
            frequencyPenalty: self.chatThread.frequencyPenalty,
            user: self.chatThread.user,
            messages: self.chatThread.messages
        )

        // Define the callback closure that appends the message to the chat thread
        let addStreamedMessageToThread: (ChatMessage) -> Void = { message in
            _ = self.addMessage(message)
        }

        let asyncByteStream = try await self.chatThread.connection.createAsyncByteStream(for: requestBody)
        
        return AsyncThrowingStream { [weak self] continuation in
            guard let strongSelf = self else {
                // Finished due to deallocated thread
                continuation.finish()
                return
            }
            strongSelf.streamingTask = Task {

                var responseMessageRole: ChatMessage.Role?
                var responseMessageContent: String?

                defer {
                    DispatchQueue.main.async {
                        strongSelf.streamingTask = nil
                    }
                }

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
                    // Finished normally
                    continuation.finish()

                } catch {
                    if Task.isCancelled {
                        // Finished due to cancellation
                        continuation.finish()
                    } else {
                        // Finished due to error
                        continuation.finish(throwing: CleverBirdError.responseParsingFailed(message: error.localizedDescription))
                    }
                }

                if let responseMessageRole, let responseMessageContent {
                    addStreamedMessageToThread(ChatMessage(role: responseMessageRole, content: responseMessageContent))
                }
            }
        }
    }

    public func cancelStreaming() {
        self.streamingTask?.cancel()
        self.streamingTask = nil
    }
}
