//  Created by B.T. Franklin on 4/15/23

import Foundation

struct HTTPURLRequester: URLRequester {

    private static let DEFAULT_LOGGER: Logger = { message in
        print(message)
    }

    private let logger: Logger

    init(logger: Logger? = nil) {
        self.logger = logger ?? Self.DEFAULT_LOGGER
    }

    func executeRequest(_ request: URLRequest,
                        withSessionConfig sessionConfig: URLSessionConfiguration?) async -> Result<JSONString, Error> {
        let session: URLSession
        if let sessionConfig {
            session = URLSession(configuration: sessionConfig)
        } else {
            session = URLSession.shared
        }

        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let error = RequestError.requestFailed("HTTP Status Code: \(httpResponse.statusCode)")
                logger("Request failed: \(error.localizedDescription)")
                return .failure(error)
            }
            return .success(JSONString(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? "{}")
        } catch {
            logger("Request failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
