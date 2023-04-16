//  Created by B.T. Franklin on 12/23/22

import Foundation

public struct OpenAIAPIConnection {

    let logger: Logger?
    let apiKey: String
    let organization: String?

    public init(apiKey: String, organization: String? = nil, logger: Logger? = nil) {
        self.apiKey = apiKey
        self.organization = organization
        self.logger = logger
    }
}
