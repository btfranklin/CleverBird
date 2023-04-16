import Foundation

public class OpenAIChatThread {

    private static let DEFAULT_LOGGER: Logger = { message in
        print(message)
    }

    private let connection: OpenAIAPIConnection
    private let model: Model
    private let temperature: Percentage
    private let top_p: Percentage?
    private let numberOfCompletionsToCreate: Int?
    private let stop: [String]?
    private let presence_penalty: Penalty?
    private let frequency_penalty: Penalty?
    private let user: String?
    private let logger: Logger

    private var messages: [ChatMessage] = []

    public init(connection: OpenAIAPIConnection,
                model: Model = .gpt4,
                temperature: Percentage = 0.7,
                top_p: Percentage? = nil,
                numberOfCompletionsToCreate: Int? = nil,
                stop: [String]? = nil,
                presence_penalty: Penalty? = nil,
                frequency_penalty: Penalty? = nil,
                user: String? = nil,
                logger: Logger? = nil) {
        self.connection = connection
        self.model = model
        self.temperature = temperature
        self.top_p = top_p
        self.numberOfCompletionsToCreate = numberOfCompletionsToCreate
        self.stop = stop
        self.presence_penalty = presence_penalty
        self.frequency_penalty = frequency_penalty
        self.user = user
        self.logger = logger ?? Self.DEFAULT_LOGGER
    }

    public func addSystemMessage(content: String) {
        addMessage(ChatMessage(role: .system, content: content))
    }

    public func addUserMessage(content: String) {
        addMessage(ChatMessage(role: .user, content: content))
    }

    public func addAssistantMessage(content: String) {
        addMessage(ChatMessage(role: .assistant, content: content))
    }

    public func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }

    public func complete() async -> ChatCompletionResponse? {

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openai.com"
        urlComponents.path = "/v1/chat/completions"
        let openAIChatCompletionURL = urlComponents.url

        var request = URLRequest(url: openAIChatCompletionURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(connection.apiKey)", forHTTPHeaderField: "Authorization")
        if let organization = connection.organization {
            request.setValue(organization, forHTTPHeaderField: "OpenAI-Organization")
        }

        let requestBody = ChatCompletionRequest(
            model: self.model.rawValue,
            temperature: self.temperature,
            top_p: self.top_p,
            n: self.numberOfCompletionsToCreate,
            stop: self.stop,
            presence_penalty: self.presence_penalty,
            frequency_penalty: self.frequency_penalty,
            user: self.user,
            messages: self.messages
        )

        do {
            let encoder = JSONEncoder()
            let httpBodyJson = try encoder.encode(requestBody)
            request.httpBody = httpBodyJson
        } catch {
            logger("Unable to convert to JSON \(error)")
            return nil
        }

        let urlRequester = self.connection.urlRequester
        let result = await urlRequester.executeRequest(request, withSessionConfig: nil)
        switch result {
        case .success(let jsonStr):
            let json = jsonStr.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let product = try decoder.decode(ChatCompletionResponse.self, from: json)
                return product
            } catch {
                logger("Error decoding ChatCompletion OpenAI API Response: \(error)")
                return nil
            }
        case .failure(let error):
            logger("Error executing request: \(error.localizedDescription)")
            return nil
        }
    }
}
