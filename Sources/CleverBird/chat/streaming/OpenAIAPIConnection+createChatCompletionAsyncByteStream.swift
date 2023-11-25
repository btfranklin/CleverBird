//  Created by B.T. Franklin on 7/27/23

import Foundation

extension OpenAIAPIConnection {
    func createChatCompletionAsyncByteStream(for body: Encodable) async throws -> URLSession.AsyncBytes {

        let request = try await createChatCompletionRequest(for: body)
        let urlRequest = try await client.makeURLRequest(for: request)
        let (asyncByteStream, response) = try await client.session.bytes(for: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw CleverBirdError.responseParsingFailed(message: "Expected response of type HTTPURLResponse, but received: \(response)")
        }

        guard (200...299).contains(response.statusCode) else {
            if response.statusCode == 401 {
                throw CleverBirdError.unauthorized(message: "Unauthorized")
            } else {
                throw CleverBirdError.requestFailed(message: "Response status code: \(response.statusCode)")
            }
        }

        return asyncByteStream
    }
}
