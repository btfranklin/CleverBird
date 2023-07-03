//  Created by B.T. Franklin on 6/14/23

/// A function that the AI can call
public struct Function: Codable {

    static public let EMPTY_PARAMETERS = Function.Parameters(
        properties: [:],
        required: []
    )

    /// The name of the function. This should match with the name used in the chat message when the function is being called.
    public let name: String

    /// An optional description of what the function does.
    public let description: String?

    /// The parameters of the function
    public let parameters: Parameters

    public init(name: String, description: String? = nil, parameters: Parameters = EMPTY_PARAMETERS) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }

    public struct Parameters: Codable {

        /// Parameter names mapped to their descriptions
        public let properties: [String: Property]

        /// Parameter names that are required for the function. If a parameter is not in this list, it is considered optional.
        public let required: [String]

        enum CodingKeys: String, CodingKey {
            case type
            case properties
            case required
        }

        public init(properties: [String:Property], required: [String]) {
            self.properties = properties
            self.required = required
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            guard type == "object" else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Expected 'object' for 'type' key"
                )
            }
            properties = try container.decode([String: Property].self, forKey: .properties)
            required = try container.decode([String].self, forKey: .required)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("object", forKey: .type)
            try container.encode(properties, forKey: .properties)
            try container.encode(required, forKey: .required)
        }
        
        public struct Property: Codable {

            /// The type of the parameter. It could be "string", "integer", etc., based on the JSON Schema types.
            public let type: JSONType

            /// The purpose of the parameter. This could help users understand what kind of input is expected.
            public let description: String?

            /// The allowed values for the parameter if it's an enum. The AI should choose from these values when invoking the function.
            public let enumCases: [String]?

            enum CodingKeys: String, CodingKey {
                case type
                case description
                case enumCases = "enum"
            }

            public init(type: JSONType, description: String? = nil, enumCases: [String]? = nil) {
                self.type = type
                self.description = description
                self.enumCases = enumCases
            }
        }

    }
}
