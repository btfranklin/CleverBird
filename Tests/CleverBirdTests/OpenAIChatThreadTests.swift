//  Created by B.T. Franklin on 4/15/23

import XCTest
@testable import CleverBird

class OpenAIChatThreadTests: XCTestCase {

    class MockURLRequester: URLRequester {
        let response: JSONString
        let logger: Logger

        init(response: JSONString) {
            self.response = response
            self.logger = { message in print(message) }
        }

        func executeRequest(_ request: URLRequest, withSessionConfig sessionConfig: URLSessionConfiguration?) async -> Result<JSONString, Error> {
            logger("Request URL: \(request.url!)")
            if let httpBody = request.httpBody, let json = try? JSONSerialization.jsonObject(with: httpBody, options: []) {
                logger("Request JSON:")
                let prettyJsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                let prettyJsonStr = String(data: prettyJsonData ?? Data(), encoding: .utf8) ?? ""
                logger(prettyJsonStr)
            }
            return .success(response)
        }
    }

    func testChatCompletion() async {
        let responseMessageContent = "The 2020 World Series was won by the Los Angeles Dodgers."
        let mockResponse = """
        {
            "id": "chatcmpl-6p9XYPYSTTRi0xEviKjjilqrWU2Ve",
            "object": "chat.completion",
            "created": 1677649420,
            "model": "gpt-4",
            "usage": {
                "prompt_tokens": 56,
                "completion_tokens": 31,
                "total_tokens": 87
            },
            "choices": [
                {
                    "message": {
                        "role": "assistant",
                        "content": "\(responseMessageContent)"
                    },
                    "finish_reason": "stop",
                    "index": 0
                }
            ]
        }
        """

        let mockURLRequester = MockURLRequester(response: mockResponse)

        let userMessageContent = "Who won the world series in 2020?"
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key", urlRequester: mockURLRequester)
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage(userMessageContent)

        XCTAssertEqual(2, chatThread.getMessages().count)
        XCTAssertEqual(1, chatThread.getNonSystemMessages().count)
        XCTAssertEqual(userMessageContent, chatThread.getNonSystemMessages().first?.content)

        let completion = await chatThread.complete()

        XCTAssertNotNil(completion, "Completion is nil")
        XCTAssertEqual(completion?.content.trimmingCharacters(in: .whitespacesAndNewlines),
                       responseMessageContent, "Unexpected assistant response")
        XCTAssertEqual(3, chatThread.getMessages().count)
        XCTAssertEqual(2, chatThread.getNonSystemMessages().count)
        XCTAssertEqual(userMessageContent, chatThread.getNonSystemMessages().first?.content)
        XCTAssertEqual(responseMessageContent, chatThread.getNonSystemMessages().last?.content)
    }

    func testTokenCount() {
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key", urlRequester: MockURLRequester(response: ""))
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage("Who won the world series in 2020?")

        let tokenCount = chatThread.tokenCount()

        XCTAssertEqual(tokenCount, 25, "Unexpected token count")
    }

}
