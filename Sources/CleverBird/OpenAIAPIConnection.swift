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

        var clientConfiguration = APIClient.Configuration(baseURL: openAIChatCompletionURL)
        clientConfiguration.encoder = encoder

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
}
