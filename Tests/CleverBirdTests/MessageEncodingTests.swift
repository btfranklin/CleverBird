//
//  ContentEncodingTests.swift
//
//
//  Created by Ronald Mannak on 4/12/24.
//

import XCTest
@testable import CleverBird

class ContentEncodingTests: XCTestCase {
    
    let text = """
        {
            "type": "text",
            "text": "What’s in this image?"
        }
        """.data(using: .utf8)!
    
    let imageURL = """
        {
            "type": "image_url",
            "image_url": {
                "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg",
            }
        }
        """.data(using: .utf8)!
    
    let imageURLDetail = """
        {
            "type": "image_url",
            "image_url": {
              "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg",
              "detail": "high"
            }
        }
        """.data(using: .utf8)!
    
    let imageData = """
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,aGVsbG8sIHdvcmxk"
          }
        }
        """.data(using: .utf8)!

    var encoder: JSONEncoder!
    var decoder: JSONDecoder!
            
    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
        
    func testTextDecoding() throws {
        let object = try decoder.decode(ChatContent.self, from: text)
        switch object {
        case .imageUrl(let detail):
            XCTFail()
        case .text(let text):
            XCTAssertEqual(text, "What’s in this image?")
        }
    }
    
    func testImageURLDecoding() throws {
        let object = try decoder.decode(ChatContent.self, from: imageURL)
    }
    
    func testImageURLDetailDecoding() throws {
        let object = try decoder.decode(ChatContent.self, from: imageURLDetail)
    }
    
    func testImageDataDecoding() throws {
        let object = try decoder.decode(ChatContent.self, from: imageData)
    }
    
    func testTextEncoding() throws {
        let content = ChatContent.text("What’s in this image?")
        let json = try encoder.encode(content)
        
        let object = try decoder.decode(ChatContent.self, from: json)
        switch object {
        case .imageUrl(let detail):
            XCTFail()
        case .text(let text):
            XCTAssertEqual(text, "What’s in this image?")
        }        
    }
    
    func testImageURLEncoding() throws {
        let content = ChatContent.imageUrl(ChatContent.URLDetail(url: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"))
        let json = try encoder.encode(content)
        let object = try decoder.decode(ChatContent.self, from: json)
        
        switch object {
        case .imageUrl(let detail):
            XCTAssertEqual(detail.url, "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")
            XCTAssertEqual(detail.detail, nil)
        case .text(let text):
            XCTFail()
        }
    }
    
    func testImageURLDetailEncoding() throws {
        let content = ChatContent.imageUrl(ChatContent.URLDetail(url: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg", detail: .high))
        let json = try encoder.encode(content)
        let object = try decoder.decode(ChatContent.self, from: json)
        
        switch object {
        case .imageUrl(let detail):
            XCTAssertEqual(detail.url, "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")
            XCTAssertEqual(detail.detail, .high)
        case .text(let text):
            XCTFail()
        }
    }
    
    func testImageDataEncoding() throws {
        let content = ChatContent.imageUrl(ChatContent.URLDetail(url: "data:image/jpeg;base64,aGVsbG8sIHdvcmxk"))
        let json = try encoder.encode(content)
        let object = try decoder.decode(ChatContent.self, from: json)
        
        switch object {
        case .imageUrl(let detail):
            XCTAssertEqual(detail.url, "data:image/jpeg;base64,aGVsbG8sIHdvcmxk")
            XCTAssertEqual(detail.detail, nil)
        case .text(let text):
            XCTFail()
        }
    }
}
