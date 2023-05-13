//  Created by B.T. Franklin on 5/5/23

import Foundation

public struct ChatMessage: Codable, Identifiable {

    public enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public let role: Role
    public let content: String
    public var id: String

    public init(role: Role,
                content: String,
                id: String? = nil) {
        self.role = role
        self.content = content

        if let id {
            self.id = id
        } else {
            var hasher = Hasher()
            hasher.combine(self.role)
            hasher.combine(self.content)
            let hashValue = abs(hasher.finalize())
            let timestamp = Int(Date.now.timeIntervalSince1970*10000)

            self.id = "chatmsg-\(hashValue)-\(timestamp)"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(Role.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        id = "pending"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }
}

extension ChatMessage: Equatable {
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
            && lhs.role == rhs.role
            && lhs.content == rhs.content
    }
}
