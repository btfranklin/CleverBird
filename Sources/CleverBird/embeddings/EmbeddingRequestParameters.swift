//  Created by B.T. Franklin on 7/28/23

public struct EmbeddingRequestParameters: Encodable {
    public let model: EmbeddingModel
    public let input: [String]
    public let user: String?

    public init(model: EmbeddingModel,
                input: [String],
                user: String? = nil) {
        self.model = model
        self.input = input
        self.user = user
    }
}
