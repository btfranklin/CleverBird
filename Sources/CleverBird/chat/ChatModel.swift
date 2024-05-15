public enum ChatModel: Codable {
    case gpt35Turbo
    case gpt4
    case gpt4Turbo
    case gpt4o
    case specific(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case _ where modelString.starts(with: "gpt-3.5"):
            self = .gpt35Turbo
        case _ where modelString.starts(with: "gpt-4o"):
            self = .gpt4o
        case _ where modelString.starts(with: "gpt-4-turbo"):
            self = .gpt4Turbo
        case _ where modelString.starts(with: "gpt-4"):
            self = .gpt4
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

extension ChatModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .gpt35Turbo:
            return "gpt-3.5-turbo"
        case .gpt4o:
            return "gpt-4o"
        case .gpt4Turbo:
            return "gpt-4-turbo"
        case .gpt4:
            return "gpt-4"
        case .specific(let string):
            return string
        }
        
    }
}
