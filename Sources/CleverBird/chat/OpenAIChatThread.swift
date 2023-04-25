import Foundation

public class OpenAIChatThread {

    private struct ChatCompletionResponse: Codable {
        struct Choice: Codable {
            let message: ChatMessage
        }
        let choices: [Choice]
    }

    private static let DEFAULT_LOGGER: Logger = { message in
        print(message)
    }

    private let connection: OpenAIAPIConnection
    private let model: Model
    private let temperature: Percentage
    private let topP: Percentage?
    private let stop: [String]?
    private let presencePenalty: Penalty?
    private let frequencyPenalty: Penalty?
    private let user: String?
    private let logger: Logger

    private var messages: [ChatMessage] = []

    public init(connection: OpenAIAPIConnection,
                model: Model = .gpt4,
                temperature: Percentage = 0.7,
                topP: Percentage? = nil,
                numberOfCompletionsToCreate: Int? = nil,
                stop: [String]? = nil,
                presencePenalty: Penalty? = nil,
                frequencyPenalty: Penalty? = nil,
                user: String? = nil,
                logger: Logger? = nil) {
        self.connection = connection
        self.model = model
        self.temperature = temperature
        self.topP = topP
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.user = user
        self.logger = logger ?? Self.DEFAULT_LOGGER
    }

    public func addSystemMessage(_ content: String) -> Self {
        addMessage(ChatMessage(role: .system, content: content))
    }

    public func addUserMessage(_ content: String) -> Self {
        addMessage(ChatMessage(role: .user, content: content))
    }

    public func addAssistantMessage(_ content: String) -> Self {
        addMessage(ChatMessage(role: .assistant, content: content))
    }

    public func addMessage(_ message: ChatMessage) -> Self {
        messages.append(message)
        return self
    }

    public func getMessages() -> [ChatMessage] {
        messages
    }

    public func getNonSystemMessages() -> [ChatMessage] {
        messages.filter { $0.role != .system }
    }
}

extension OpenAIChatThread {
    public func complete() async -> ChatMessage? {

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
            model: self.model,
            temperature: self.temperature,
            topP: self.topP,
            stop: self.stop,
            presencePenalty: self.presencePenalty,
            frequencyPenalty: self.frequencyPenalty,
            user: self.user,
            messages: self.messages
        )

        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
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
                let response = try decoder.decode(ChatCompletionResponse.self, from: json)
                if let choice = response.choices.first {
                    _ = addMessage(choice.message)
                    return choice.message
                } else {
                    logger("Error decoding ChatCompletion OpenAI API Response: Unable to parse completion")
                    return nil
                }
            } catch {
                logger("Error decoding ChatCompletion OpenAI API Response: \(error)")
                return nil
            }

        case .failure(let error):
            logger("Error executing request: \(error.localizedDescription)")
            return nil
        }
    }}

extension OpenAIChatThread {
    public func tokenCount() -> Int {

        let tokenEncoder: TokenEncoder
        do {
            tokenEncoder = try TokenEncoder()
        } catch {
            logger("Unable to create token encoder: \(error)")
            return -1
        }

        var tokensPerMessage: Int

        switch self.model {
        case .gpt35Turbo:
            tokensPerMessage = 4
        case .gpt4:
            tokensPerMessage = 3
        }

        var numTokens = 0
        for message in messages {
            do {
                let roleTokens = try tokenEncoder.encode(text: message.role.rawValue).count
                let contentTokens = try tokenEncoder.encode(text: message.content).count

                numTokens += roleTokens + contentTokens + tokensPerMessage
            } catch {
                logger("Error encoding text: \(error)")
            }
        }

        numTokens += 3  // every reply is primed with assistant

        return numTokens
    }
}
