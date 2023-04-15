import Foundation

/// Represents a value that can be between `-2.0` and `2.0`.
public struct Penalty: Equatable {
  /// The actual value.
  public let value: Decimal
  
  /// Creates the penalty value, clamped between `-2.0` and `2.0`.
  /// - Parameter value: The value.
  public init(_ value: Decimal) {
    self.value = Self.clamp(value)
  }
}

extension Penalty {
  /// Clamps the value between `-2.0` and `2.0`.
  ///
  /// - Parameter value: The value to clamp.
  /// - Returns: The clamped value.
  public static func clamp(_ value: Decimal) -> Decimal {
    return min(2.0, max(-2.0, value))
  }
}

extension Penalty: ExpressibleByFloatLiteral {
  /// Allows creation of a penalty directly with a `Double`.
  public init(floatLiteral value: Double) {
    self.init(Decimal(value))
  }
}

extension Penalty: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.init(container.decode(Decimal.self))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.value)
  }
}
