//  Created by B.T. Franklin on 4/15/23

import Foundation

public protocol URLRequester {
    func executeRequest(_ request: URLRequest,
                        withSessionConfig sessionConfig: URLSessionConfiguration?) async throws -> JSONString
}
