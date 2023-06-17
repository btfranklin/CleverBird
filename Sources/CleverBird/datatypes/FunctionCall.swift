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
                let value = try JSONValue.processJSONValue(argValue)

                // Perform type checking against expectedType
                let expectedType = function?.parameters?.properties[argName]?.type
                if !value.conformsTo(type: expectedType) {
                    throw DecodingError.dataCorruptedError(forKey: .arguments,
                                                           in: container,
                                                           debugDescription: "Invalid type for \(argName). Expected \(expectedType?.rawValue ?? "unknown"), but got \(value.typeDescription)")
                }

                decodedArguments[argName] = value
            }

            arguments = decodedArguments
        } else {
            arguments = nil
        }

        self.name = functionName
    }

}
