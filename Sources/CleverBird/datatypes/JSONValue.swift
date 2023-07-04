//  Created by B.T. Franklin on 6/15/23

import Foundation

public enum JSONValue: Codable {
    case null
    case string(String)
    case boolean(Bool)
    case number(Double)
    case integer(Int)
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
        case .null:
            try container.encodeNil()
        case .string(let x):
            try container.encode(x)
        case .boolean(let x):
            try container.encode(x)
        case .number(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        }
    }

    static func createFromValue(_ value: Any, ofType type: JSONType) throws -> JSONValue {

        switch type {

        case .null:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value provided for null type"))

        case .string:
            guard value is String else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value was not expected type of String"))
            }
            return .string(value as! String)

        case .boolean:
            guard value is Bool else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value was not expected type of Bool"))
            }
            return .boolean(value as! Bool)

        case .number:
            guard value is Double else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value was not expected type of Double"))
            }
            return .number(value as! Double)

        case .integer:
            guard value is Int else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value was not expected type of Int"))
            }
            return .integer(value as! Int)

        case .array:
            guard value is [Any] else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Value was not expected type of [Any]"))
            }
            let arrayValue = value as! [Any]
            return .array(try arrayValue.map { item in
                try createFromValue(item, ofType: .string)
            })
        }
    }

}
