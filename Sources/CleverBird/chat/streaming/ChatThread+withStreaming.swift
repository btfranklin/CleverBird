//  Created by B.T. Franklin on 5/11/23

extension ChatThread {
    public func withStreaming() -> StreamableChatThread {
        return StreamableChatThread(chatThread: self)
    }
}
