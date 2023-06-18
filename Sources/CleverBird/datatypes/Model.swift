public enum Model: Codable {
    case gpt35Turbo
    case gpt4
    case specific(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case _ where modelString.starts(with: "gpt-3.5"):
            self = .gpt35Turbo
        case _ where modelString.starts(with: "gpt-4"):
            self = .gpt4
        default:
            self = .specific(modelString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let modelString: String

        switch self {
        case .gpt35Turbo:
            modelString = "gpt-3.5-turbo"
        case .gpt4:
            modelString = "gpt-4"
        case .specific(let specificString):
            modelString = specificString
        }

        try container.encode(modelString)
    }

}
