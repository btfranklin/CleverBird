//  Created by B.T. Franklin on 7/27/23

import Get

private let chatCompletionPath = "/v1/chat/completions"

extension OpenAIAPIConnection {
    func createChatCompletionRequest(for body: Encodable) async throws -> Request<ChatCompletionResponse> {
        Request<ChatCompletionResponse>(
            path: chatCompletionPath,
            method: .post,
            body: body,
            headers: self.requestHeaders)
    }
}
