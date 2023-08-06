# CleverBird

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/btfranklin/CleverBird/blob/main/LICENSE)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![GitHub tag](https://img.shields.io/github/tag/btfranklin/CleverBird.svg)](https://github.com/btfranklin/CleverBird)
[![build](https://github.com/btfranklin/CleverBird/actions/workflows/build.yml/badge.svg)](https://github.com/btfranklin/CleverBird/actions/workflows/build.yml)

`CleverBird` is a Swift Package that provides a convenient way to interact with OpenAI's chat APIs and perform various tasks, including token counting and encoding. The package is designed to deliver a superior Developer Experience (DX) by making the chat thread the center of the interactions. While there are numerous Swift Packages available for interacting with OpenAI, `CleverBird` stands out due to its focus on simplicity and seamless integration of the handy `TokenEncoder` class. 

`CleverBird` is focused narrowly on chat-based interactions, and making them awesome.

Please note that `CleverBird` is an *unofficial* package, not provided by OpenAI itself.

## Features

- Asynchronous API calls with Swift's async/await syntax
- Supports token counting and encoding with the `TokenEncoder` class
- Allows customization of various parameters, such as temperature and penalties
- Streamed responses for real-time generated content
- Built-in token counting for usage limit calculations

## Usage Instructions

Import the `CleverBird` package:

```swift
import CleverBird
```

Initialize an `OpenAIAPIConnection` with your API key. Please note that API keys should always be loaded from environment variables, and not hard-coded into your source. After you have loaded your API key, pass it to the initializer of the connection:

```swift
let openAIAPIConnection = OpenAIAPIConnection(apiKey: <OPENAI_API_KEY>)
```

Create a `ChatThread` instance with the connection, and add system, user, or assistant messages to the chat thread:

```swift
let chatThread = ChatThread(connection: openAIAPIConnection)
    .addSystemMessage(content: "You are a helpful assistant.")
    .addUserMessage(content: "Who won the world series in 2020?")
```

The `ChatThread` initializer includes a mandatory `connection` parameter and various optional parameters. You can set defaults for your thread by using any subset of these optional parameters:

```swift
let chatThread = ChatThread(
    connection: openAIAPIConnection, 
    model: .gpt4, 
    temperature: 0.7, 
    maxTokens: 500
)
```

In the example above, we initialized a `ChatThread` with a specific model, temperature, and maximum number of tokens. All parameters except `connection` are optional. The full list of parameters is as follows:

- `connection`: The API connection object (required).
- `model`: The model to use for the completion.
- `temperature`: Controls randomness. Higher values (up to 1) generate more random outputs, while lower values generate more deterministic outputs.
- `topP`: This is the nucleus sampling parameter. It specifies the probability mass to cover with the prediction.
- `stop`: An array of strings. The model will stop generating when it encounters any of these strings.
- `maxTokens`: The maximum number of tokens to generate.
- `presencePenalty`: A penalty for using tokens that have already been used.
- `frequencyPenalty`: A penalty for using frequent tokens.
- `user`: The user ID associated with the chat.

Generate a completion using the chat thread:

```swift
let completion = try await chatThread.complete()
```

The response messages are automatically appended onto the thread, so
you can continue interacting with it by just adding new user messages
and requesting additional completions.

You can customize each call to `complete()` with the same parameters as the `ChatThread` initializer, allowing you to override the defaults set during initialization:

```swift
let completion = try await chatThread.complete(
    model: .gpt35Turbo, 
    temperature: 0.5, 
    maxTokens: 300
)
```

In this example, we override the model, temperature, and maximum number of tokens for this specific completion. The parameters you can use in the `complete()` method include:

- `model`: The model to use for the completion.
- `temperature`: Controls randomness. Higher values (up to 1) generate more random outputs, while lower values generate more deterministic outputs.
- `topP`: This is the nucleus sampling parameter. It specifies the probability mass to cover with the prediction.
- `stop`: An array of strings. The model will stop generating when it encounters any of these strings.
- `maxTokens`: The maximum number of tokens to generate.
- `presencePenalty`: A penalty for using tokens that have already been used.
- `frequencyPenalty`: A penalty for using frequent tokens.

All parameters are optional and default to the values set during `ChatThread` initialization if not specified.

Generate a completion with streaming using the streaming version of a chat thread:

```swift
let chatThread = ChatThread(connection: openAIAPIConnection).withStreaming()
let completionStream = try await chatThread.complete()
for try await messageChunk in completionStream {
    print("Received message chunk: \(messageChunk)")
}
```

Just like with the non-streamed completion, the message will be automatically
appended onto the thread after it has finished streaming, but the stream
allows you to see it as it's coming through.

Calculate the token count for messages in the chat thread:

```swift
let tokenCount = try chatThread.tokenCount()
```

If you need to count tokens or encode/decode text outside of a chat thread,
use the `TokenEncoder` class:

```swift
let tokenEncoder = try TokenEncoder(model: .gpt3)
let encodedTokens = try tokenEncoder.encode(text: "Hello, world!")
let decodedText = try tokenEncoder.decode(tokens: encodedTokens)
```

## Using Functions

`CleverBird` supports Function Calls. This powerful feature allows developers to define their own custom commands, making it easier to control the behavior of the AI. Function Calls can be included in the `ChatThread` and used in the `complete()` method.

First, define your function parameters and the function itself. The `Function.Parameters` class is used to set the properties and required parameters of your function.

```swift
let getCurrentWeatherParameters = Function.Parameters(
    properties: [
        "location": Function.Parameters.Property(type: .string,
                                                 description: "The city and state, e.g. San Francisco, CA"),
        "format": Function.Parameters.Property(type: .string,
                                               description: "The temperature unit to use. Infer this from the user's location.",
                                               enumCases: ["celsius", "fahrenheit"])
    ],
    required: ["location", "format"])

let getCurrentWeather = Function(name: "get_current_weather",
                                 description: "Get the current weather",
                                 parameters: getCurrentWeatherParameters)
```

Then, initialize your `ChatThread` with your API connection and an array of functions:

```swift
let openAIAPIConnection = OpenAIAPIConnection(apiKey: "your_api_key_here")
let chatThread = ChatThread(connection: openAIAPIConnection,
                            functions: [getCurrentWeather])
    .addSystemMessage(content: "You are a helpful assistant.")
```

Finally, call the `complete()` function to generate a response. If the assistant needs to perform a function during the conversation, it will use the function definitions you provided.

Please note that functions are only supported in non-streaming completions at this time.

## License

`CleverBird` was written by B.T. Franklin ([@btfranklin](https://github.com/btfranklin)) from 2023 onward and is licensed under the [MIT](https://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
