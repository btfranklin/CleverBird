//  Created by B.T. Franklin on 7/25/23

public enum EmbeddingModel: Codable {
    case textEmbedding3Small
    case textEmbedding3Large
    case textEmbeddingAda002
    case specific(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case "text-embedding-3-small":
            self = .textEmbedding3Small
        case "text-embedding-3-large":
            self = .textEmbedding3Large
        case "text-embedding-ada-002":
            self = .textEmbeddingAda002
        default:
            self = .specific(modelString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let modelString = self.description

        try container.encode(modelString)
    }
}

extension EmbeddingModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .textEmbedding3Small:
            return "text-embedding-3-small"
        case .textEmbedding3Large:
            return "text-embedding-3-large"
        case .textEmbeddingAda002:
            return "text-embedding-ada-002"
        case .specific(let string):
            return string
        }
    }
}
