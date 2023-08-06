import Foundation

/// Represents a value that can be between `0.0` and `1.0`.
public struct Percentage: Equatable {
    public let value: Decimal

    /// Creates the percentage, clamping between `0.0` and `1.0`.
    public init(_ value: Decimal) {
        self.value = Self.clamp(value)
    }
}

extension Percentage {
    /// Clamps the value between `0.0` and `1.0`.
    public static func clamp(_ value: Decimal) -> Decimal {
        return min(1.0, max(0.0, value))
    }
}

extension Percentage: ExpressibleByFloatLiteral {
    /// Allows the ``Percentage`` to be created via direct assignment from a `Double`.
    public init(floatLiteral value: Double) {
        self.init(Decimal(value))
    }
}

extension Percentage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(Decimal.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
