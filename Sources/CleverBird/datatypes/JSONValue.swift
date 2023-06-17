//  Created by B.T. Franklin on 6/15/23

import Foundation

public enum JSONValue: Codable {
    case null
    case string(String)
    case boolean(Bool)
    case number(Double)
    case integer(Int)
    case object([String: JSONValue])
    case array([JSONValue])

    var typeDescription: String {
        switch self {
        case .null:
            return "null"
        case .string(_):
            return "string"
        case .boolean(_):
            return "boolean"
        case .number(_):
            return "number"
        case .integer(_):
            return "integer"
        case .object(_):
            return "object"
        case .array(_):
            return "array"
        }
    }

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

    func conformsTo(type: JSONType?) -> Bool {
        switch (self, type) {
        case (.string(_), .string),
            (.number(_), .number),
            (.integer(_), .integer),
            (.object(_), .object),
            (.array(_), .array),
            (.boolean(_), .boolean),
            (.null, .null):
            return true
        default:
            return false
        }
    }

    static func processJSONValue(_ value: Any) throws -> JSONValue {
        switch value {
        case let stringValue as String:
            return .string(stringValue)
        case let numberValue as Double:
            if numberValue.truncatingRemainder(dividingBy: 1) == 0 {
                // The number is actually an integer
                return .integer(Int(numberValue))
            } else {
                // The number is a true double
                return .number(numberValue)
            }
        case let intValue as Int:
            return .integer(intValue)
        case let boolValue as Bool:
            return .boolean(boolValue)
        case is NSNull:
            return .null
        case let arrayValue as [Any]:
            return .array(try arrayValue.map(processJSONValue))
        case let objectValue as [String: Any]:
            var result: [String: JSONValue] = [:]
            for (key, value) in objectValue {
                result[key] = try processJSONValue(value)
            }
            return .object(result)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON value"))
        }
    }

}
