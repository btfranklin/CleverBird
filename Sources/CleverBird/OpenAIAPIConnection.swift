//  Created by B.T. Franklin on 12/23/22

import Foundation
import Get

public class OpenAIAPIConnection {

    let apiKey: String
    let organization: String?
    let client: APIClient
    let requestHeaders: [String:String]

    public init(apiKey: String,
                organization: String? = nil,
                scheme: String = "https",
                host: String = "api.openai.com",
                port: Int = 443) {
        self.apiKey = apiKey
        self.organization = organization

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
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
}
