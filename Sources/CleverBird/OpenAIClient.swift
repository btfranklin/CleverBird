//  Created by B.T. Franklin on 12/23/22

import Foundation

public struct OpenAIClient {

    public typealias Logger = (String) -> Void

    let apiKey: String
    let organization: String?
    let logger: Logger?

    public init(apiKey: String, organization: String? = nil, logger: Logger? = nil) {
        self.apiKey = apiKey
        self.organization = organization
        self.logger = logger
    }

    func executeRequest(request: URLRequest,
                        withSessionConfig sessionConfig: URLSessionConfiguration? = nil) async throws -> Data {
        let session: URLSession
        if let config = sessionConfig {
            session = URLSession(configuration: config)
        } else {
            session = URLSession.shared
        }

        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let error = OpenAIClientError.requestFailed("HTTP Status Code: \(httpResponse.statusCode)")
                logger?("Request failed: \(error.localizedDescription)")
                throw error
            }
            return data
        } catch {
            logger?("error: \(error.localizedDescription)")
            throw error
        }
    }

}

enum OpenAIClientError: Error {
    case requestFailed(String)
}

struct OpenAIResponseHandler {
    func decodeChatCompletionJson(jsonString: String) -> ChatCompletionResponse? {
        let json = jsonString.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(ChatCompletionResponse.self, from: json)
            return product

        } catch {
            print("Error decoding ChatCompletion OpenAI API Response: \(error)")
        }

        return nil
    }
}
