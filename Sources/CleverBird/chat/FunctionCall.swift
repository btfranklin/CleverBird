//  Created by B.T. Franklin on 6/15/23

import Foundation

public struct FunctionCall: Codable {
    public let name: String
    public let arguments: [String: JSONValue]?

    enum CodingKeys: String, CodingKey {
        case name
        case arguments
    }

    init(name: String, arguments: [String: JSONValue]? = nil) {
        self.name = name
        self.arguments = arguments
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let functionName = try container.decode(String.self, forKey: .name)

        // Find the corresponding Function object for this FunctionCall
        let function = FunctionRegistry.shared.getFunction(withName: functionName)

        // Decode the arguments as a JSON string
        let argumentsString = try container.decode(String.self, forKey: .arguments)

        if let data = argumentsString.data(using: .utf8) {

            // Parse the JSON string into a dictionary
            let argumentsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            guard let argumentsDict else {
                throw DecodingError.dataCorruptedError(forKey: .arguments, in: container, debugDescription: "Arguments were nil.")
            }

            // Initialize an empty dictionary to hold the decoded arguments
            var decodedArguments: [String: JSONValue] = [:]

            // Decode each argument
            for (argName, argValue) in argumentsDict {
                guard let argType = function?.parameters.properties[argName]?.type else {
                    throw DecodingError.dataCorruptedError(forKey: .arguments,
                                                           in: container,
                                                           debugDescription: "No type provided for \(argName). Decoding not possible.")
                }
                let value = try JSONValue.createFromValue(argValue, ofType: argType)

                decodedArguments[argName] = value
            }

            arguments = decodedArguments
        } else {
            arguments = nil
        }

        self.name = functionName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        let argumentsAsString = try String(data: JSONEncoder().encode(self.arguments), encoding: .utf8) ?? ""
        try container.encode(argumentsAsString, forKey: .arguments)
    }
}
