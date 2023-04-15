public struct Token: Equatable, Hashable {
    public let value: Int

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
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

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
