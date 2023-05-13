//  Created by B.T. Franklin on 12/23/22

import Foundation
import Get

public class OpenAIAPIConnection {

    private static let CHAT_COMPLETION_PATH = "/v1/chat/completions"

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
        let openAIChatCompletionURL = urlComponents.url

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var clientConfiguration = APIClient.Configuration(baseURL: openAIChatCompletionURL)
        clientConfiguration.encoder = encoder
        clientConfiguration.decoder = decoder

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

    func createRequest(for body: Encodable) async throws -> Request<ChatCompletionResponse> {
        Request<ChatCompletionResponse>(
            path: Self.CHAT_COMPLETION_PATH,
            method: .post,
            body: body,
            headers: self.requestHeaders)
    }

    func createAsyncByteStream(for body: Encodable) async throws -> URLSession.AsyncBytes {

        let request = try await createRequest(for: body)
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

