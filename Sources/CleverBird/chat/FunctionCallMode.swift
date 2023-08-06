//  Created by B.T. Franklin on 6/14/23

public enum FunctionCallMode: Codable {
    case auto
    case none
    case specific(FunctionName)

    public struct FunctionName: Codable {
        let name: String
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            switch string {
            case "auto":
                self = .auto
            case "none":
                self = .none
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value for FunctionCallMode")
            }
        } else {
            self = .specific(try FunctionName(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .auto:
            try container.encode("auto")
        case .none:
            try container.encode("none")
        case .specific(let functionName):
            try functionName.encode(to: encoder)
        }
    }
}
