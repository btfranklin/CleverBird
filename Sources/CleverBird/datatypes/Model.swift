public enum Model: String, Codable {
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let modelString = try container.decode(String.self)

        switch modelString {
        case _ where modelString.starts(with: "gpt-3.5"):
            self = .gpt35Turbo
        case _ where modelString.starts(with: "gpt-4"):
            self = .gpt4
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot initialize Model from invalid String value: \(modelString)")
        }
    }
}
