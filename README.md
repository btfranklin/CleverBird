# CleverBird

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/btfranklin/CleverBird/blob/main/LICENSE)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![GitHub tag](https://img.shields.io/github/tag/btfranklin/CleverBird.svg)](https://github.com/btfranklin/CleverBird)
[![build](https://github.com/btfranklin/CleverBird/actions/workflows/build.yml/badge.svg)](https://github.com/btfranklin/CleverBird/actions/workflows/build.yml)

`CleverBird` is a Swift Package that provides a convenient way to interact with OpenAI's chat APIs and perform various tasks, including token counting and encoding. The package is designed to deliver a superior Developer Experience (DX) by making the chat thread the center of the interactions. While there are numerous Swift Packages available for interacting with OpenAI, `CleverBird` stands out due to its focus on simplicity and seamless integration of the handy `TokenEncoder` class. 

`CleverBird` is focused narrowly on chat-based interactions, and making them awesome.

## Features

- Asynchronous API calls with Swift's async/await syntax
- Supports token counting and encoding with the `TokenEncoder` class
- Allows customization of various parameters, such as temperature and penalties
- Streamed responses for real-time generated content using the `completeWithStreaming()` method
- Built-in token counting for usage limit calculations

## Usage Instructions

Import the `CleverBird` package:

```swift
import CleverBird
```

Initialize an `OpenAIAPIConnection` with your API key:

```swift
let openAIAPIConnection = OpenAIAPIConnection(apiKey: "your_api_key_here")
```

Create a `ChatThread` instance with the connection, and
add system, user, or assistant messages to the chat thread:

```swift
let chatThread = ChatThread(connection: openAIAPIConnection)
    .addSystemMessage(content: "You are a helpful assistant.")
    .addUserMessage(content: "Who won the world series in 2020?")
```

Generate a completion using the chat thread:

```swift
let completion = await chatThread.complete()
```

The response messages are automatically appended onto the thread, so
you can continue interacting with it by just adding new user messages
and requesting additional completions.

Generate a completion with streaming using the chat thread:

```swift
let completionStream = try await chatThread.completeWithStreaming()
for try await messageChunk in completionStream {
    print("Received message chunk: \(messageChunk)")
}
```

As with the non-streamed completion, the message will be automatically
appended onto the thread after it has finished streaming, but the stream
allows you to see it as it's coming through.

Calculate the token count for messages in the chat thread:

```swift
let tokenCount = chatThread.tokenCount()
```

If you need to count tokens or encode/decode text outside of a chat thread,
use the `TokenEncoder` class:

```swift
let tokenEncoder = try TokenEncoder(model: .gpt3)
let encodedTokens = try tokenEncoder.encode(text: "Hello, world!")
let decodedText = try tokenEncoder.decode(tokens: encodedTokens)
```


## License

`CleverBird` was written by B.T. Franklin ([@btfranklin](https://github.com/btfranklin)) from 2023 onward and is licensed under the [MIT](https://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
