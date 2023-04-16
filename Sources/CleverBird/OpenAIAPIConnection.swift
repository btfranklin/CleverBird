//  Created by B.T. Franklin on 12/23/22

import Foundation

public struct OpenAIAPIConnection {

    let urlRequester: URLRequester
    let apiKey: String
    let organization: String?

    public init(apiKey: String, organization: String? = nil, urlRequester: URLRequester?) {
        self.apiKey = apiKey
        self.organization = organization
        self.urlRequester = urlRequester ?? HTTPURLRequester()
    }
}
