//  Created by B.T. Franklin on 4/15/23

import XCTest
@testable import CleverBird

class OpenAIChatThreadTests: XCTestCase {

    func testThreadLength() async {
        let userMessageContent = "Who won the world series in 2020?"
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key")
        let chatThread = ChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage(userMessageContent)

        XCTAssertEqual(2, chatThread.getMessages().count)
        XCTAssertEqual(1, chatThread.getNonSystemMessages().count)
        XCTAssertEqual(userMessageContent, chatThread.getNonSystemMessages().first?.content)
    }

    func testTokenCount() throws {
        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key")
        let chatThread = ChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .addUserMessage("Who won the world series in 2020?")
        let tokenCount = try chatThread.tokenCount()
        
        XCTAssertEqual(tokenCount, 25, "Unexpected token count")
    }

    func testFunctionCallMessage() throws {

        let getCurrentWeatherParameters = Function.Parameters(
            properties: [
                "location": Function.Parameters.Property(type: .string,
                                                         description: "The city and state, e.g. San Francisco, CA"),
                "format": Function.Parameters.Property(type: .string,
                                                       description: "The temperature unit to use. Infer this from the users location.",
                                                       enumCases: ["celsius", "fahrenheit"])
            ],
            required: ["location", "format"])

        let getCurrentWeather = Function(name: "get_current_weather",
                                         description: "Get the current weather",
                                         parameters: getCurrentWeatherParameters)

        let getNDayWeatherForecastParameters = Function.Parameters(
            properties: [
                "location": Function.Parameters.Property(type: .string,
                                                         description: "The city and state, e.g. San Francisco, CA"),
                "format": Function.Parameters.Property(type: .string,
                                                       description: "The temperature unit to use. Infer this from the users location.",
                                                       enumCases: ["celsius", "fahrenheit"]),
                "num_days": Function.Parameters.Property(type: .integer,
                                                         description: "The number of days to forecast")
            ],
            required: ["location", "format", "num_days"])

        let getNDayWeatherForecast = Function(name: "get_n_day_weather_forecast",
                                              description: "Get an N-day weather forecast",
                                              parameters: getNDayWeatherForecastParameters)

        let openAIAPIConnection = OpenAIAPIConnection(apiKey: "fake_api_key")
        let functionCall = FunctionCall(name: "testFunc", arguments: ["arg1": .string("value1")])
        let chatThread = ChatThread(connection: openAIAPIConnection)
            .addSystemMessage("You are a helpful assistant.")
            .setFunctions([getCurrentWeather, getNDayWeatherForecast])
            .addMessage(try! ChatMessage(role: .assistant, functionCall: functionCall))
        let tokenCount = try chatThread.tokenCount()

        XCTAssertEqual(tokenCount, 241, "Unexpected token count")
    }

    func testInvalidMessageCreation() {
        let functionCall = FunctionCall(name: "testFunc", arguments: ["arg1": .string("value1")])
        XCTAssertThrowsError(try ChatMessage(role: .assistant)) { error in
            XCTAssertEqual(error as? CleverBirdError, CleverBirdError.invalidMessageContent)
        }
        XCTAssertThrowsError(try ChatMessage(role: .function, functionCall: functionCall)) { error in
            XCTAssertEqual(error as? CleverBirdError, CleverBirdError.invalidFunctionMessage)
        }
    }
}
