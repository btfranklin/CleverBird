/// A single token. Each token references a string of one or more characters.
public struct Token: Equatable, Hashable {
    /// The `Int` value of the token.
    public let value: Int

    /// Initializes a new token.
    /// - Parameter value: The token value.
    public init(_ value: Int) {
        self.value = value
    }
}

extension Token: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(Int.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension Token: ExpressibleByIntegerLiteral {
    /// A ``Token`` can be initialized directly with an `Int` literal.
    /// - Parameter value: The value.
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

// Note: This allows Tokens to be converted to and from `String`s, which are used when tokens are used as dictionary key in ``Embedding`` results.

extension Token: RawRepresentable {
    public var rawValue: String {
        String(value)
    }

    public init?(rawValue: String) {
        guard let intValue = Int(rawValue) else {
            return nil
        }
        self.value = intValue
    }
}

extension Token: CustomStringConvertible {
    public var description: String { rawValue }
}
