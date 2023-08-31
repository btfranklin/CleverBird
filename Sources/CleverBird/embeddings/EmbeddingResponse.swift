//  Created by B.T. Franklin on 7/27/23

struct EmbeddingResponse: Codable {

    struct EmbeddingData: Codable {
        let embedding: [Double]
        let index: Int
    }

    struct Usage: Codable {
        let promptTokens: Int
        let totalTokens: Int
    }

    let data: [EmbeddingData]
    let usage: Usage
}
