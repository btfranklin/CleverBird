//  Created by B.T. Franklin on 4/15/23

import XCTest
@testable import CleverBird

class OpenAIChatThreadTests: XCTestCase {

    func testThreadLength() async {
        let userMessageContent = "Who won the world series in 2020?"
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key")
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage(userMessageContent)

        XCTAssertEqual(2, chatThread.getMessages().count)
        XCTAssertEqual(1, chatThread.getNonSystemMessages().count)
        XCTAssertEqual(userMessageContent, chatThread.getNonSystemMessages().first?.content)
    }

    func testTokenCount() {
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key")
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage("Who won the world series in 2020?")

        let tokenCount = chatThread.tokenCount()

        XCTAssertEqual(tokenCount, 25, "Unexpected token count")
    }

}
