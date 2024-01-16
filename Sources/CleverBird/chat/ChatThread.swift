//  Created by B.T. Franklin on 5/5/23

public class ChatThread: Codable {

    let user: String?
    
    var messages: [ChatMessage] = []
    var functions: [Function]?

    public init(user: String? = nil,
                functions: [Function]? = nil) {
        self.user = user
        self.functions = functions
    }

    @discardableResult
    public func addSystemMessage(_ content: String) -> Self {
        do {
            try addMessage(ChatMessage(role: .system, content: content))
        } catch {
            print(error.localizedDescription)
        }
        return self
    }

    @discardableResult
    public func addUserMessage(_ content: String) -> Self {
        do {
            try addMessage(ChatMessage(role: .user, content: content))
        } catch {
            print(error.localizedDescription)
        }
        return self
    }

    @discardableResult
    public func addAssistantMessage(_ content: String) -> Self {
        do {
            try addMessage(ChatMessage(role: .assistant, content: content))
        } catch {
            print(error.localizedDescription)
        }
        return self
    }

    @discardableResult
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

    @discardableResult
    public func setFunctions(_ functions: [Function]?) -> Self {
        self.functions = functions
        return self
    }

    public func getFunctions() -> [Function]? {
        functions
    }

    @discardableResult
    public func addFunctionResponse(_ content: String, for functionCall: FunctionCall) -> ChatThread {
        do {
            let responseMessage = try ChatMessage(role: .function,
                                                  content: content,
                                                  functionCall: functionCall)
            messages.append(responseMessage)
        } catch {
            print(error.localizedDescription)
        }
        return self
    }
}
