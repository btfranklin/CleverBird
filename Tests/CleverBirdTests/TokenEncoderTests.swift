import XCTest
@testable import CleverBird

final class TokenEncoderTests: XCTestCase {

    func testEncodingAndDecoding() throws {
        let testCases = [
            "Hello, world!",
            "This is a test string.",
            "Testing Unicode characters: 😃🌍🚀",
            "A more complex example: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            """
            The term "Swifty" refers to writing code in a way that follows the design patterns, idioms, and best practices of the Swift programming language. Writing Swifty code usually means adhering to the following principles:

            Clarity: Code should be easy to read and understand. Prefer clear and expressive names for variables, functions, and types.
            Safety: Swift emphasizes safety by using strong typing, optionals, and error handling to minimize the chance of runtime errors.
            Conciseness: Code should be concise, yet expressive, using features like type inference, trailing closures, and other Swift idioms.
            Performance: Swift is designed for high performance, so Swifty code should take advantage of Swift's optimizations and not unnecessarily sacrifice performance.
            Protocol-oriented programming: Swift encourages the use of protocols and protocol extensions to create flexible, reusable components.
            Use of Swift-specific features: Swift has many powerful features, like generics, closures, and pattern matching. Swifty code should make good use of these features where appropriate.
            """,
        ]

        let tokenEncoder = try TokenEncoder(model: .gpt3)

        for text in testCases {
            let encoded = try tokenEncoder.encode(text: text)
            let decoded = try tokenEncoder.decode(tokens: encoded)
            XCTAssertEqual(text, decoded)
        }
    }
}
