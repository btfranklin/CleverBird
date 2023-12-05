//  Created by B.T. Franklin on 7/27/23

public struct EmbeddingResponse: Codable {

    public struct EmbeddingData: Codable {
        let embedding: Vector
        let index: Int
    }

    public struct Usage: Codable {
        let promptTokens: Int
        let totalTokens: Int
    }

    public let data: [EmbeddingData]
    public let usage: Usage
}
