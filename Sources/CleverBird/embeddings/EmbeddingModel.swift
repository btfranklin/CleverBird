//  Created by B.T. Franklin on 7/25/23

public enum EmbeddingModel: Codable {
    case textEmbeddingAda002
    case specific(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case "text-embedding-ada-002":
            self = .textEmbeddingAda002
        default:
            self = .specific(modelString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let modelString: String

        switch self {
        case .textEmbeddingAda002:
            modelString = "text-embedding-ada-002"
        case .specific(let specificString):
            modelString = specificString
        }

        try container.encode(modelString)
    }
}
