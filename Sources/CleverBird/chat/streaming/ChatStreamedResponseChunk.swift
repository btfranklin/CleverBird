//  Created by B.T. Franklin on 5/5/23

import Foundation

struct ChatStreamedResponseChunk: Codable {
    struct Choice: Codable {
        struct Delta: Codable {
            let role: ChatMessage.Role?
            let content: String?
        }
        let delta: Delta

        enum FinishReason: String, Codable {
            case stop
            case length
            case contentFilter
        }
        let finishReason: FinishReason?
    }
    let choices: [Choice]
    let id: String
}

extension ChatStreamedResponseChunk {
    static private var CHUNK_DECODER: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func decode(from chunkString: String) -> ChatStreamedResponseChunk? {
        guard chunkString.hasPrefix("data: "),
              let data = chunkString.dropFirst(6).data(using: .utf8) else {
            return nil
        }
        return try? CHUNK_DECODER.decode(ChatStreamedResponseChunk.self, from: data)
    }
}
