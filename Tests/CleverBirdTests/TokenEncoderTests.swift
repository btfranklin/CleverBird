import XCTest
@testable import CleverBird

final class TokenEncoderTests: XCTestCase {

    func testEncodingAndDecoding() throws {
        let testCases = [
            "Hello, world!",
            "This is a test string.",
            "Testing Unicode characters: 😃🌍🚀",
            "A more complex example: Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        ]

        let tokenEncoder = try tokenEncoderType.init(model: .gpt3)

        for text in testCases {
            let encoded = try tokenEncoder.encode(text: text)
            let decoded = try tokenEncoder.decode(tokens: encoded)
            XCTAssertEqual(text, decoded)
        }
    }
}
