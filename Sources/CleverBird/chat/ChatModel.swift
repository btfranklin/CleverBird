public enum ChatModel: Codable {
    case gpt35Turbo
    case gpt4
    case gpt4Turbo
    case specific(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case _ where modelString.starts(with: "gpt-3.5"):
            self = .gpt35Turbo
        case _ where modelString.starts(with: "gpt-4"):
            self = .gpt4Turbo
        default:
            self = .specific(modelString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let modelString = self.description
        
        try container.encode(modelString)
    }
    
    public var modelString: String {
        switch self {
        case .gpt35Turbo:
            return "gpt-3.5-turbo"
        case .gpt4:
            return "gpt-4"
        case .gpt4Turbo:
            return "gpt-4-turbo-preview"
        case .specific(let specificString):
            return specificString
        }
    }
}

extension ChatModel: CustomStringConvertible {
    public var description: String {
        return modelString
    }
}
