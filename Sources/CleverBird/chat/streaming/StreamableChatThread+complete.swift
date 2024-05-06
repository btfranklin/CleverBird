//  Created by B.T. Franklin on 5/5/23

import Foundation

extension StreamableChatThread {

    public func complete(using connection: OpenAIAPIConnection,
                         model: ChatModel = .gpt4,
                         temperature: Percentage = 0.7,
                         topP: Percentage? = nil,
                         stop: [String]? = nil,
                         maxTokens: Int? = nil,
                         presencePenalty: Penalty? = nil,
                         frequencyPenalty: Penalty? = nil,
                         streamOptions: StreamOptions? = nil) async throws -> AsyncThrowingStream<String, Swift.Error> {

        let requestBody = ChatCompletionRequestParameters(
            model: model,
            temperature: temperature,
            topP: topP,
            stream: true,
            stop: stop,
            maxTokens: maxTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            user: self.chatThread.user,
            messages: self.chatThread.messages,
            streamOptions: streamOptions
        )

        // Define the callback closure that appends the message to the chat thread
        let addStreamedMessageToThread: (ChatMessage) -> Void = { message in
            self.addMessage(message)
        }

        let asyncByteStream = try await connection.createChatCompletionAsyncByteStream(for: requestBody)
        
        return AsyncThrowingStream { [weak self] continuation in
            guard let strongSelf = self else {
                // Finished due to deallocated thread
                continuation.finish()
                return
            }
            strongSelf.streamingTask = Task {

                var responseMessageId: String?
                var responseMessageRole: ChatMessage.Role?
                var responseMessageContent: String?

                defer {
                    DispatchQueue.main.async {
                        strongSelf.streamingTask = nil
                    }
                    if let responseMessageRole, let responseMessageContent {
                        do {
                            var streamedMessage = try ChatMessage(role: responseMessageRole,
                                                                  content: responseMessageContent,
                                                                  id: responseMessageId)
                            streamedMessage.id = responseMessageId ?? "unspecified"
                            addStreamedMessageToThread(streamedMessage)
                        } catch {
                            print("error while creating streamed message: \(error.localizedDescription)")
                        }
                    }
                }

                do {
                    for try await line in asyncByteStream.lines {
                        guard let responseChunk = ChatStreamedResponseChunk.decode(from: line) else {
                            print(line)
                            break
                        }

                        responseMessageId = responseChunk.id

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
                        if let usage = responseChunk.usage {
                            strongSelf.usage = usage
                            print(usage)
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
            }
        }
    }

    public func cancelStreaming() {
        self.streamingTask?.cancel()
        self.streamingTask = nil
    }
}
