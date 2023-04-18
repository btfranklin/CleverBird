# CleverBird

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbtfranklin%2FCleverBird%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/btfranklin/CleverBird)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/btfranklin/CleverBird/blob/main/LICENSE)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![GitHub tag](https://img.shields.io/github/tag/btfranklin/CleverBird.svg)](https://github.com/btfranklin/CleverBird)
[![build](https://github.com/btfranklin/CleverBird/workflows/build/badge.svg)](https://github.com/btfranklin/actions?query=workflow%3Abuild)

`CleverBird` is a Swift Package that provides a convenient way to interact with OpenAI's GPT-4 API and perform various tasks, including token counting and encoding. The package mainly focuses on the `OpenAIClient` and `TokenEncoder` classes.

## Features

- Asynchronous API calls with Swift's async/await syntax
- Supports token counting and encoding with the `TokenEncoder` class
- Allows customization of various parameters, such as temperature and penalties
- Easily adjustable to support future changes or additional OpenAI API endpoints
- Installable via Swift Package Manager

## Usage Instructions

Import the `CleverBird` package:

```swift
import CleverBird
```

Initialize an `OpenAIAPIConnection` with your API key:

```swift
let openAIAPIConnection = OpenAIAPIConnection(apiKey: "your_api_key_here")
```

Create an `OpenAIChatThread` instance with the connection, and
add system, user, or assistant messages to the chat thread:

```swift
let chatThread = OpenAIChatThread(connection: openAIAPIConnection)
    .addSystemMessage(content: "You are a helpful assistant.")
    .addUserMessage(content: "Who won the world series in 2020?")
```

Generate a completion using the chat thread:

```swift
let completionResponse = await chatThread.complete()
```

If you need to count tokens or encode/decode text, use the `TokenEncoder` class:

```swift
let tokenEncoder = try TokenEncoder(model: .gpt3)
let encodedTokens = try tokenEncoder.encode(text: "Hello, world!")
let decodedText = try tokenEncoder.decode(tokens: encodedTokens)
```

## License

`CleverBird` was written by B.T. Franklin ([@btfranklin](https://github.com/btfranklin)) from 2023 onward and is licensed under the [MIT](https://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).