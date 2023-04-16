//  Created by B.T. Franklin on 4/15/23

import Foundation

struct HTTPURLRequester: URLRequester {

    private let logger: Logger?

    init(logger: Logger? = nil) {
        self.logger = logger
    }

    func executeRequest(request: URLRequest,
                        withSessionConfig sessionConfig: URLSessionConfiguration? = nil) async throws -> JSONString {
        let session: URLSession
        if let config = sessionConfig {
            session = URLSession(configuration: config)
        } else {
            session = URLSession.shared
        }

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let error = RequestError.requestFailed("HTTP Status Code: \(httpResponse.statusCode)")
            logger?("Request failed: \(error.localizedDescription)")
            throw error
        }
        return JSONString(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? "{}"
    }
}

enum RequestError: Error {
    case requestFailed(String)
}
