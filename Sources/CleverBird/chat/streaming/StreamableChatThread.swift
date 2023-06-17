//  Created by B.T. Franklin on 5/11/23

public class StreamableChatThread {
    
    var streamingTask: Task<Void, Error>?
    let chatThread: ChatThread

    init(chatThread: ChatThread) {
        self.chatThread = chatThread
    }

    @discardableResult
    public func addSystemMessage(_ content: String) -> Self {
        self.chatThread.addSystemMessage(content)
        return self
    }

    @discardableResult
    public func addUserMessage(_ content: String) -> Self {
        self.chatThread.addUserMessage(content)
        return self
    }

    @discardableResult
    public func addAssistantMessage(_ content: String) -> Self {
        self.chatThread.addAssistantMessage(content)
        return self
    }

    @discardableResult
    public func addMessage(_ message: ChatMessage) -> Self {
        self.chatThread.addMessage(message)
        return self
    }

    public func getMessages() -> [ChatMessage] {
        self.chatThread.messages
    }

    public func getNonSystemMessages() -> [ChatMessage] {
        self.chatThread.getNonSystemMessages()
    }

    public func tokenCount() throws -> Int {
        try self.chatThread.tokenCount()
    }
}
