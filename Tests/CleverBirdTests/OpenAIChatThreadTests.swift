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
                        "content": "The 2020 World Series was won by the Los Angeles Dodgers."
                    },
                    "finish_reason": "stop",
                    "index": 0
                }
            ]
        }
        """

        let mockURLRequester = MockURLRequester(response: mockResponse)

        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key", urlRequester: mockURLRequester)
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage(content: "You are a helpful assistant.")
            .addUserMessage(content: "Who won the world series in 2020?")


        let completionResponse = await chatThread.complete()

        XCTAssertNotNil(completionResponse, "Completion response is nil")
        XCTAssertEqual(completionResponse?.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
                       "The 2020 World Series was won by the Los Angeles Dodgers.", "Unexpected assistant response")
    }

    func testTokenCount() {
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key", urlRequester: MockURLRequester(response: ""))
        let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
            .addSystemMessage(content: "You are a helpful assistant.")
            .addUserMessage(content: "Who won the world series in 2020?")

        let tokenCount = chatThread.tokenCount()

        XCTAssertEqual(tokenCount, 25, "Unexpected token count")
    }

}
