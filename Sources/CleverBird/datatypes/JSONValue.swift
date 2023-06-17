//  Created by B.T. Franklin on 6/15/23

public enum JSONValue: Codable {
    case null
    case string(String)
    case boolean(Bool)
    case number(Double)
    case integer(Int)
    case object([String: JSONValue])
    case array([JSONValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
        } else if let x = try? container.decode(Bool.self) {
            self = .boolean(x)
        } else if let x = try? container.decode(Double.self) {
            self = .number(x)
        } else if let x = try? container.decode(Int.self) {
            self = .integer(x)
        } else if let x = try? container.decode([String: JSONValue].self) {
            self = .object(x)
        } else if let x = try? container.decode([JSONValue].self) {
            self = .array(x)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong type for JSONValue")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .boolean(let x):
            try container.encode(x)
        case .number(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        case .object(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}
