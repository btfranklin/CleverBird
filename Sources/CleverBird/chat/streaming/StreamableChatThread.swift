//  Created by B.T. Franklin on 5/11/23

public class StreamableChatThread {
    
    var streamingTask: Task<Void, Error>?
    let chatThread: ChatThread

    init(chatThread: ChatThread) {
        self.chatThread = chatThread
    }

    public func addSystemMessage(_ content: String) -> Self {
        _ = self.chatThread.addSystemMessage(content)
        return self
    }

    public func addUserMessage(_ content: String) -> Self {
        _ = self.chatThread.addUserMessage(content)
        return self
    }

    public func addAssistantMessage(_ content: String) -> Self {
        _ = self.chatThread.addAssistantMessage(content)
        return self
    }

    public func addMessage(_ message: ChatMessage) -> Self {
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
