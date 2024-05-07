//  Created by Ronald Mannak on 4/12/24.

import Foundation
import XCTest
@testable import CleverBird

class MessageContentTests: XCTestCase {
    
    func testURL() {
        let content = MessageContent.URLDetail(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")!)
        XCTAssertEqual(content.url, "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")        
    }
    
    func testBase64() {
        let data = "Hello, world".data(using: .utf8)!
        let content = MessageContent.URLDetail(imageData: data)
        XCTAssertEqual(content.url, "data:image/jpeg;base64,SGVsbG8sIHdvcmxk")
    }
}
