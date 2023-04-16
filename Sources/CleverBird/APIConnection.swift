//  Created by B.T. Franklin on 4/15/23

import Foundation

public protocol APIConnection {
    typealias Logger = (String) -> Void
    var logger: Logger? { get }
}

extension APIConnection {
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
                let error = RequestError.requestFailed("HTTP Status Code: \(httpResponse.statusCode)")
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

public enum RequestError: Error {
    case requestFailed(String)
}
