//  Created by B.T. Franklin on 12/23/22

import Foundation
import Get

public class OpenAIAPIConnection {

    private let chatCompletionPath = "/v1/chat/completions"
    private let embeddingsPath = "/v1/embeddings"

    let apiKey: String
    let organization: String?
    let client: APIClient

    private let requestHeaders: [String:String]

    public init(apiKey: String, organization: String? = nil) {
        self.apiKey = apiKey
        self.organization = organization

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openai.com"
        let openAIAPIURL = urlComponents.url

        let clientConfiguration = APIClient.Configuration(baseURL: openAIAPIURL)
        clientConfiguration.encoder.keyEncodingStrategy = .convertToSnakeCase
        clientConfiguration.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.client = APIClient(configuration: clientConfiguration)

        var requestHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        if let organization {
            requestHeaders["OpenAI-Organization"] = organization
        }
        self.requestHeaders = requestHeaders
    }

    func createChatCompletionRequest(for body: Encodable) async throws -> Request<ChatCompletionResponse> {
        Request<ChatCompletionResponse>(
            path: self.chatCompletionPath,
            method: .post,
            body: body,
            headers: self.requestHeaders)
    }

    func createChatCompletionAsyncByteStream(for body: Encodable) async throws -> URLSession.AsyncBytes {

        let request = try await createChatCompletionRequest(for: body)
        let urlRequest = try await client.makeURLRequest(for: request)
        let (asyncByteStream, response) = try await client.session.bytes(for: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw CleverBirdError.responseParsingFailed(message: "Expected response of type HTTPURLResponse, but received: \(response)")
        }

        guard (200...299).contains(response.statusCode) else {
            throw CleverBirdError.requestFailed(message: "Response status code: \(response.statusCode)")
        }

        return asyncByteStream
    }
}
