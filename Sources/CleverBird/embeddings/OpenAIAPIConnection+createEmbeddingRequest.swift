//  Created by B.T. Franklin on 7/27/23

import Get

private let embeddingsPath = "/v1/embeddings"

extension OpenAIAPIConnection {
    func createEmbeddingRequest(for body: Encodable) async throws -> Request<EmbeddingResponse> {
        Request<EmbeddingResponse>(
            path: embeddingsPath,
            method: .post,
            body: body,
            headers: self.requestHeaders)
    }
}
