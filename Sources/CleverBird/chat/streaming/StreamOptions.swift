//  Created by Ronald Mannak on 5/6/24.

import Foundation

public struct StreamOptions: Codable {
    
    let includeUsage: Bool
    
    public init(includeUsage: Bool) {
        self.includeUsage = includeUsage
    }
}
